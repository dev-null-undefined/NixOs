{
  lib,
  pkgs,
  ...
}: let
  # currently, there is some friction between sway and gtk:
  # https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland
  # the suggested way to set gtk settings is with gsettings
  # for gsettings to work, we need to tell it where the schemas are
  # using the XDG_DATA_DIR environment variable
  # run at the end of sway config
  configure-gtk = let
    schema = pkgs.gsettings-desktop-schemas;
    datadir = "${schema}/share/gsettings-schemas/${schema.name}";
  in
    pkgs.writeShellScriptBin "configure-gtk"
    ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      export GTK_THEME=Orchis-Dark
      gsettings set $gnome_schema gtk-theme $GTK_THEME
      gsettings set $gnome_schema icon-theme Papirus-Dark
      gsettings set $gnome_schema cursor-theme phinger-cursors
      gsettings set $gnome_schema font-name Sans
    '';
in {
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

    # Custom gtk thingy from nix wiki https://nixos.wiki/wiki/Sway
    configure-gtk
    glib

    pasystray

    grimblast
    fuzzel
    waybar-hyprland

    swaylock-effects

    showmethekey

    swaynotificationcenter
  ];
}
