{pkgs, ...}: {
  wayland.windowManager.hyprland.settings = {
    # Execute favorite apps at launch
    exec-once = [
      "copyq"
      "swaync"
      "waybar"
      "pasystray"
      "batsignal -c 10"
      "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "blueman-applet"
      "sleep 1 && syncthingtray"
      "${pkgs.libsForQt5.polkit-kde-agent.outPath}/libexec/polkit-kde-authentication-agent-1"
    ];
  };
}
