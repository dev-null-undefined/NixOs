# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./packages/packages.nix
      ./grub-savedefault.nix
      ./users/default.nix
      ./de/dwm.nix
    ];
  # Use the systemd-boot EFI boot loader.
  boot = {
      loader = {
        grub = {
          efiSupport = true;
          device = "nodev";
          useOSProber = true;
        };
        efi.canTouchEfiVariables = true;
      };
  };

  networking.hostName = "idk";
  networking.hostId = "69faa160";
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;
  # networking.wireless.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  networking.useDHCP = false;

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  environment.pathsToLink = [ "/libexec" ];

  system.stateVersion = "21.05"; # Did you read the comment?
}
