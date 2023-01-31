{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.hyprland.homeManagerModules.default
    ../common/wayland
  ];

  programs = {
    zsh.profileExtra = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        exec Hyprland &> /dev/null
      fi
    '';
  };

  home.packages = with pkgs; [
    pasystray

    grimblast
    wofi
    waybar-hyprland

    swaylock-effects

    showmethekey
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig =
      (import ./monitors.nix {
        inherit lib;
        inherit (config) monitors;
      })
      + (import ./config.nix {
        inherit config lib;
      });
  };
}
