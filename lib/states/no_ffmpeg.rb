module FFMPEGTrimmer
  class States
    class NoFFMPEG < CyberarmEngine::GuiState
      def setup
        theme(THEME)

        stack(width: 1.0, height: 1.0, padding: 64) do
          background 0xff_252525

          stack(width: 1.0, height: 1.0) do
            background 0xff_400000

            flow(fill: true)
            banner "Failed to find FFMPEG.", text_align: :center, width: 1.0
            flow(fill: true)
          end
        end
      end
    end
  end
end
