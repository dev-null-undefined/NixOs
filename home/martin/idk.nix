{lib, ...}: {
  wayland.windowManager.hyprland.settings = {
    monitor = lib.mkForce [
      ",preferred,auto,1"
      "DP-4,1920x1080@144,0x0,1"
      "DP-3,1920x1080@144,0x0,1"
      "DP-2,2560x1440@60,0x0,1"
      "eDP-1,1920x1080@144,1920x0,1"
    ];
  };
}
