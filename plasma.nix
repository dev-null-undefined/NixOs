{ config, pkgs, ... }:

{
  imports = [ ./nvidia-sync.nix ];
  
  services.xserver = {
    enable = true;
    desktopManager.plasma5.enable = true;
    displayManager.sddm.enable = true;
  };
  
  environment.systemPackages = with pkgs; [
    kde-gtk-config
  ];
}
