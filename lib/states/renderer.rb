module FFMPEGTrimmer
  class States
    class Renderer < CyberarmEngine::GuiState
      def setup
        theme(THEME)

        @start_time = @options[:start_time]
        @clip_duration = @options[:clip_duration]
        @file = @options[:file].to_s

        unless File.exist?(@file)
          pop_state

          return
        end

        @thread = Thread.new do
          start_time = Gosu.milliseconds
          `ffmpeg.exe -y -ss #{@start_time} -t #{@clip_duration} -i "#{@file}" -c copy -map 0 "temp/trimmed_#{File.basename(@file)}"`

          loop do
            break if Gosu.milliseconds - start_time >= 500.0

              sleep 0.1
          end

          pop_state
        end

        stack(width: 1.0, height: 1.0, padding: 64) do
          background 0xff_252525

          stack(width: 1.0, height: 1.0) do
            background 0xff_353535

            flow(fill: true)
            banner "Trimming clip, please wait...", text_align: :center, width: 1.0
            flow(fill: true)

            button("Cancel") do
              @thread&.kill

              pop_state
            end
          end
        end
      end
    end
  end
end
