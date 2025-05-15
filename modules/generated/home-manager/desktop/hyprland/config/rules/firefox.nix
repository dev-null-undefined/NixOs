{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      # Firefox stuff
      # make Firefox PiP window floating and sticky
      "float, title:Picture-in-Picture"
      "pin, title:Picture-in-Picture"

      # throw sharing indicators away
      "workspace special silent, title:Firefox — Sharing Indicator"
      "workspace special silent, title:.*is sharing (your screen|a window)."
    ];
  };
}
