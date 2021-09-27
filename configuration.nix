# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./packages/packages.nix
      ./users/default.nix
      # ./de/dwm.nix
    ];
  # Use the systemd-boot EFI boot loader.
  boot.loader.grub = {
	version = 2;
	enable = true;
	device = "/dev/sdd";
  };

  networking.hostName = "server_idk";
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  networking.useDHCP = false;

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };


  system.stateVersion = "21.05"; # Did you read the comment?
}
