module FFMPEGTrimmer
  class States
    class Editor < CyberarmEngine::GuiState
      PLACEHOLDER_IMAGE = Gosu::Image.from_blob(128, 128, "\x00\x80\x00\xFF" * 128 * 128)

      def setup
        theme(THEME)

        @file = @options[:filename]
        @duration = duration

        window.caption = "FFMPEG Trimmer: #{@file}"

        generate_preview_frames

        stack(width: 1.0, height: 1.0, padding: 8) do
          background 0xff_252525

          @frames_container = flow(width: 1.0, height: 256) do
            background 0xff_353535

            @start_frame_image = image preview_image(:start), width: 0.33, height: 1.0, padding: 2
            @middle_frame_image = image preview_image(:middle), width: 0.33, height: 1.0, padding: 2
            @end_frame_image = image preview_image(:end), width: 0.33, height: 1.0, padding: 2
          end

          stack(width: 1.0, fill: true, padding: 2, margin_top: 8) do
            background 0xff_151515

            flow(width: 1.0, height: 36) do
              button("Import Again") {  pop_state }

              flow(fill: true)

              path = "#{ROOT_PATH}/temp".gsub("/", "\\")
              button("Open Folder") {  `explorer "#{path}"` }
            end

            caption "Trim Start:", width: 1.0, text_align: :center
            flow(width: 1.0, height: 24, padding: 2) do
              @trim_start_label = caption format_duration(0.0), width: 96
              @trim_start = slider fill: true, height: 1.0, range: 0..@duration, value: 0.0
            end

            caption "Trim End:", width: 1.0, text_align: :center, margin_top: 16
            flow(width: 1.0, height: 24, padding: 2) do
              @trim_end_label = caption format_duration(@duration), width: 96
              @trim_end = slider fill: true, height: 1.0, range: 0..@duration, value: @duration
            end

            @clip_duration_label = tagline "Clip Duration: #{format_duration(@duration)} (#{@duration}s)", width: 1.0, text_align: :center, margin_top: 16

            flow(fill: true)

            flow(width: 1.0, height: 48, margin_top: 16, padding: 8) do
              button "Update Preview", height: 1.0 do
                update_preview
              end

              flow(fill: true)

              button "Limit to Selection", height: 1.0 do
                @trim_start.range = @trim_end.range = @trim_start.value..@trim_end.value
                request_recalculate
              end

              button "Reset Limit", height: 1.0 do
                @trim_start.range = @trim_end.range = 0.0..@duration
                request_recalculate
              end

              flow(fill: true)

              @export_video_btn = button "Export Video", height: 1.0 do
                export_video
              end
            end
          end
        end

        @last_frames_container_width = @frames_container.width
        @last_frames_container_height = @frames_container.height

        @selected_frames_changed_at = Gosu.milliseconds
        @selected_frames_changed = false
        @last_trim_start = @trim_start.value
        @last_trim_end = @trim_end.value

        @render_queue = []
        @main_thread_queue = []

        Thread.new do
          loop do
            @render_queue.shift&.call(self)

            sleep 0.1
          end
        end
      end

      def update
        super

        preserve_aspect_ratio

        if @frames_container.width != @last_frames_container_width || @frames_container.height != @last_frames_container_height
          @last_frames_container_width = @frames_container.width
          @last_frames_container_height = @frames_container.height

          request_recalculate
        end

        @trim_start_label.value = format_duration(@trim_start.value)
        @trim_end_label.value = format_duration(@trim_end.value)

        if @last_trim_start != @trim_start.value || @last_trim_end != @trim_end.value
          @selected_frames_changed_at = Gosu.milliseconds
          @selected_frames_changed = true
        end

        if @selected_frames_changed && (Gosu.milliseconds - @selected_frames_changed_at) >= 250
          @selected_frames_changed = false

          update_preview
        end

        @last_trim_start = @trim_start.value
        @last_trim_end = @trim_end.value

        @clip_duration = (@last_trim_end - @last_trim_start).clamp(0.0, @duration)
        @clip_duration_label.value = "Clip Duration: #{format_duration(@clip_duration)} (#{@clip_duration.round(2)}s)"

        @export_video_btn.enabled = (@last_trim_start - @last_trim_end).negative?

        @main_thread_queue.shift&.call(self)
      end

      def preserve_aspect_ratio
        max_width = @frames_container.width / 3.0
        max_height = 0

        [@start_frame_image, @middle_frame_image, @end_frame_image].each do |img|
          img.style.width = max_width - 4
          img.style.height = (max_width.to_f / img.value.width) * img.value.height

          max_height = img.height unless img.value == PLACEHOLDER_IMAGE
        end

        @frames_container.style.height = max_height

        request_recalculate_for(@frames_container)
      end

      def duration
        Float(`ffprobe -i \"#{@file}\" -show_entries format=duration -v quiet -of csv=\"p=0\"`.to_s.strip)
      end

      def format_duration(time)
        hours = time / 60 / 60
        minutes = (time / 60) % 60.0
        seconds = time % 60.0

        format("%02d:%02d:%02d", hours, minutes, seconds)
      end

      def generate_preview_frames
        start_time = @trim_start ? @trim_start.value : 0.0
        end_time = @trim_end ? (@trim_end.value <= @duration - 1.0 ? @trim_end.value : @trim_end.value - 1.0 ) : @duration - 1.0
        middle_time = start_time + (end_time - start_time) / 2

        times = {
          start: start_time,
          middle: middle_time,
          end: end_time
        }

        times.keys.each { |k| File.delete("temp/#{k}.png") if File.exist?("temp/#{k}.png") }

        times.each do |key, value|
          IO.popen("ffmpeg.exe -y -skip_frame nokey -vsync vfr -ss #{value} -i \"#{@file}\" -frames:v 1 -vf \"scale=720x405\" \"temp/#{key}.png\"", err: [:child, :out]) do
          end
        end
      end

      def preview_image(type)
        path = "temp/#{type}.png"
        path = nil unless File.exist?(path)

        path ? Gosu::Image.new(path) : PLACEHOLDER_IMAGE
      end

      def update_preview
        # @render_queue.clear

        @render_queue << proc do
          generate_preview_frames

          @main_thread_queue << proc do
            [:start, :middle, :end].each do |sym|
              instance_variable_get(:"@#{sym}_frame_image").value = preview_image(sym)
            end
          end
        end
      end

      def export_video
        push_state(States::Renderer, start_time: @trim_start.value, clip_duration: @clip_duration, file: @file)
      end
    end
  end
end
