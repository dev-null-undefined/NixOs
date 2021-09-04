
{ config, pkgs, ... }:

{
  imports = [ ./nvidia-offload.nix ];
  services.xserver = {
    enable = true;

    desktopManager = {
      gnome.enable = true;
    };
   
    displayManager = {
      gdm.enable = true;
      gdm.wayland = false;
    };
  };
}
