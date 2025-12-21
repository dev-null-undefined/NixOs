{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      # █░█░█ █ █▄░█ █▀▄ █▀█ █░█░█   █▀█ █░█ █░░ █▀▀ █▀
      # ▀▄▀▄▀ █ █░▀█ █▄▀ █▄█ ▀▄▀▄▀   █▀▄ █▄█ █▄▄ ██▄ ▄█
      "float on, match:class file_progress"
      "float on, match:class confirm"
      "float on, match:class dialog"
      "float on, match:class download"
      "float on, match:class notification"
      "float on, match:class error"
      "float on, match:class splash"
      "float on, match:class confirmreset"
      "float on, match:title Open File"
      "float on, match:title branchdialog"
      "float on, match:class Rofi"
      "animation none, match:class Rofi"
      "float on, match:class pavucontrol-qt"
      "float on, match:class pavucontrol"
      "float on, match:class file-roller"
      "fullscreen on, match:class wlogout"
      "float on, match:title wlogout"
      "fullscreen on, match:title wlogout"
      "float on, match:title Media viewer"
      "float on, match:title Volume Control"
      "size 800 600, match:title Volume Control"
      "move 75 44%, match:title Volume Control"
    ];
  };
}
