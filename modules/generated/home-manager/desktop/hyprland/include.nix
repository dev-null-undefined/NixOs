{
  lib,
  pkgs,
  ...
}: {
  generated.home.desktop.common.wayland.enable = lib.mkDefault true;

  home.packages = with pkgs; [
    # Low battery notification daemon
    batsignal

    glib

    pasystray

    grimblast
    wofi
    slurp

    showmethekey

    swaynotificationcenter
  ];

  wayland.windowManager.hyprland.enable = true;
}
