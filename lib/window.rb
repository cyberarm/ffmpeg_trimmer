module FFMPEGTrimmer
  ROOT_PATH = File.expand_path("..", __dir__)

  class Window < CyberarmEngine::Window
    def setup
      self.show_cursor = true
      self.show_stats_plotter = false
      window.caption = "FFMPEG Trimmer"

      if ffmpeg_available?
        push_state(States::Importer)
      else
        push_state(States::NoFFMPEG)
      end
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
