{
  lib,
  pkgs,
  ...
}: {
  generated.home.desktop.common.wayland.enable = lib.mkDefault true;

  programs = {
    zsh.profileExtra = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        exec sway --unsupported-gpu &> /dev/null
      fi
    '';
  };

  home.packages = with pkgs; [
    # Low battery notification daemon
    batsignal

    glib

    pasystray

    grimblast
    fuzzel

    showmethekey

    swaynotificationcenter
  ];
}
