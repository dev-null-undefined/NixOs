{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      # Firefox stuff
      # make Firefox PiP window floating and sticky
      "match:title Picture-in-Picture, float on"
      "match:title Picture-in-Picture, pin on"

      # throw sharing indicators away
      "match:title Firefox — Sharing Indicator, workspace special silent"
      "match:title .*is sharing (your screen|a window)., workspace special silent"
    ];
  };
}
