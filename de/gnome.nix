
{ config, pkgs, ... }:

{
  imports = [ 
    ../nvidia-offload.nix
    ./default.nix
  ];
  services.xserver = {
    desktopManager = {
      gnome.enable = true;
    };
   
    displayManager = {
      gdm.enable = true;
      gdm.wayland = false;
    };
  };
}
