{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      # █░█░█ █ █▄░█ █▀▄ █▀█ █░█░█   █▀█ █░█ █░░ █▀▀ █▀
      # ▀▄▀▄▀ █ █░▀█ █▄▀ █▄█ ▀▄▀▄▀   █▀▄ █▄█ █▄▄ ██▄ ▄█
      "float, file_progress"
      "float, confirm"
      "float, dialog"
      "float, download"
      "float, notification"
      "float, error"
      "float, splash"
      "float, confirmreset"
      "float, title:Open File"
      "float, title:branchdialog"
      "float, Rofi"
      "animation none,Rofi"
      "float, pavucontrol-qt"
      "float, pavucontrol"
      "float, file-roller"
      "fullscreen, wlogout"
      "float, title:wlogout"
      "fullscreen, title:wlogout"
      "float, title:^(Media viewer)$"
      "float, title:^(Volume Control)$"
      "size 800 600, title:^(Volume Control)$"
      "move 75 44%, title:^(Volume Control)$"
    ];

    windowrulev2 = [
      # Attempt to make jetbrains work number 2
      # search dialog
      "dimaround,class:^(jetbrains-.*)$,floating:1,title:^(?!win)"
      "center,class:^(jetbrains-.*)$,floating:1,title:^(?!win)"
      # autocomplete & menus
      "noanim,class:^(jetbrains-.*)$,title:^(win.*)$"
      "noinitialfocus,class:^(jetbrains-.*)$,title:^(win.*)$"
      "rounding 0,class:^(jetbrains-.*)$,title:^(win.*)$"

      # Firefox stuff
      # make Firefox PiP window floating and sticky
      "float, title:^(Picture-in-Picture)$"
      "pin, title:^(Picture-in-Picture)$"

      # throw sharing indicators away
      "workspace special silent, title:^(Firefox — Sharing Indicator)$"
      "workspace special silent, title:^(.*is sharing (your screen|a window)\.)$"

      # Spotify
      "tile, class:^(Spotify)$"

      # copyq
      "float, class:^(com\.github\.hluk\.copyq)$, title:^(.* — CopyQ)$"
    ];
  };
}
