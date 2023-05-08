begin
  require_relative "../cyberarm_engine/lib/cyberarm_engine"
rescue LoadError
  require "cyberarm_engine"
end

require_relative "lib/window"
require_relative "lib/theme"
require_relative "lib/states/no_ffmpeg"
require_relative "lib/states/importer"
require_relative "lib/states/editor"
require_relative "lib/states/renderer"

FFMPEGTrimmer::Window.new(width: 1280, height: 720, resizable: true).show
