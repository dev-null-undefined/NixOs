# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{

  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./packages/packages.nix
    ./grub-savedefault.nix
    ./users/default.nix
    ./de/gnome.nix
    ./services/services.nix
    ./yubikey/yubikey.nix
  ];

  networking.hostName = "idk";
  networking.hostId = "69faa160";
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;
  # networking.wireless.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  # Change default time limit for unit stop
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=5s
  '';

    # Use the systemd-boot EFI boot loader.
  boot.plymouth = {
    enable = true;
    themePackages = [ pkgs.adi1090x-plymouth ];
    theme = "loader_2";
  };

  networking.useDHCP = false;

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  system.stateVersion = "22.05"; # Did you read the comment?
}
