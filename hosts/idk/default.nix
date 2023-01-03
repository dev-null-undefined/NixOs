# Help is available in the default.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, inputs, ... }:

{

  imports = [ # Include the results of the hardware scan.
    inputs.nixos-hardware.nixosModules.msi-gs60
    ../common/network-manager.nix

    ../common/de/dwm.nix
    ../common/plymouth.nix

    ../common/services/syncthing.nix
    ../common/services/mariadb.nix

    ./yubikey/yubikey.nix
  ];

  networking.hostId = "69faa160";

  system.stateVersion = "22.11"; # Did you read the comment?
}
