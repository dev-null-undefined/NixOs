{ config, pkgs, ... }:

{
  imports = [ ./fonts.nix ./audio/audio.nix ];

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
    gnome-icon-theme
  ];

  programs = {
    seahorse.enable = true;
    noisetorch.enable = true;
  };

  services.gnome.gnome-keyring.enable = true;

  hardware.bluetooth.settings.General = {
    ControllerMode = "bredr";
    Enable = "Source,Sink,Media,Socket";
  };

  hardware.enableAllFirmware = true;

}
