{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      # Firefox stuff
      # make Firefox PiP window floating and sticky
      "float on, match:title Picture-in-Picture"
      "pin on, match:title Picture-in-Picture"

      # throw sharing indicators away
      "workspace special silent, match:title Firefox — Sharing Indicator"
      "workspace special silent, match:title .*is sharing (your screen|a window)."
    ];
  };
}
