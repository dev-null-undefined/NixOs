
{ config, pkgs, ... }:

{
  imports = [ 
    ./fonts.nix
    ./audio/audio.nix
  ];

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.xserver = {
    enable = true;
    layout = "us";
    # Enable touchpad support (enabled default in most desktopManager).
    libinput = {
        enable = true;
        touchpad.naturalScrolling = true;
    };
  };
  
  environment.systemPackages = with pkgs; [
    dunst
    orchis-theme
    vimix-gtk-themes
    papirus-icon-theme
    gnome.seahorse
  ];
}
