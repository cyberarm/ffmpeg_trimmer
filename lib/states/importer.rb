module FFMPEGTrimmer
  class States
    class Importer < CyberarmEngine::GuiState
      def setup
        stack(width: 1.0, height: 1.0, padding: 64) do
          background 0xff_252525

          stack(width: 1.0, height: 1.0) do
            background 0xff_353535

            flow(fill: true)
            banner "Drag and drop video here...", text_align: :center, width: 1.0
            flow(fill: true)
          end
        end

        @active_file = nil
      end

      def update
        super

        if @active_file
          push_state(States::Editor, filename: @active_file)
        end
      end

      def drop(filename)
        @active_file = filename
      end
    end
  end
end
