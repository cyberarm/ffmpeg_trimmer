module FFMPEGTrimmer
  class Window < CyberarmEngine::Window
    def setup
      self.show_cursor = true
      self.show_stats_plotter = false

      if ffmpeg_available?
        push_state(States::Importer)
      else
        push_state(States::NoFFMPEG)
      end

      # push_state(States::Editor, filename: "S:\\Videos\\2023-05-07 10-16-33.mkv")
      push_state(States::Renderer)
    end

    def ffmpeg_available?
      IO.popen("ffmpeg -version") do
      end

      true
    rescue Errno::ENOENT
      false
    end
  end
end
