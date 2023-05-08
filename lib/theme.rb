module FFMPEGTrimmer
  THEME = {
    TextBlock: {
      font: "Noto Mono",
      text_static: true,
      text_border: true,
      text_border_color: 0x88_000000
    },
    ToolTip: {
      text_size: 18
    },
    Button: {
      border_color: 0xff_252525,
      padding_left: 16,
      padding_right: 16,
      text_size: 20,
      height: 1.0,
      background: 0xff_008000,
      hover: {
        background: 0xff_00a000,
        color: 0xff_ffffff
      },
      active: {
        background: 0xff_006000,
        color: 0xff_aaaaaa
      }
    },
    Slider: {
      padding_left: 0,
      padding_right: 0,
      background: 0xff_002000,
      border_color: 0xff_008000
    },
    Handle: {
      padding_left: 4,
      padding_right: 4,
      border_thickness: 0
    }
  }.freeze
end
