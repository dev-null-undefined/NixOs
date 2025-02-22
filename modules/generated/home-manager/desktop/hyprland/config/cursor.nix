{config, ...}: let
  pointer = config.home.pointerCursor;
in {
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      env = [
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "HYPRCURSOR_THEME,${pointer.name}"
        "HYPRCURSOR_SIZE,${toString pointer.size}"
        "XCURSOR_SIZE,${toString pointer.size}"
      ];
      exec-once = [
        # set cursor for HL itself
        "hyprctl setcursor ${pointer.name} ${toString pointer.size}"
      ];
      cursor.no_hardware_cursors = true;
    };
  };
}
