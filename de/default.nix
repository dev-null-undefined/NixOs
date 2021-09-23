
{ config, pkgs, ... }:

{
  imports = [ 
    ./fonts.nix
  ];

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

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
}
