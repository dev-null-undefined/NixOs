{ config, pkgs, ... }:

{
  imports = [ ../nvidia-offload.nix ./default.nix ];
  hardware.pulseaudio.enable = false;
  services.xserver = {
    desktopManager = { gnome.enable = true; };

    displayManager = {
      gdm.enable = true;
      gdm.wayland = false;
    };
  };
}
