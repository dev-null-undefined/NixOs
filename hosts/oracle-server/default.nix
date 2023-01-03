# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{

  imports = [
    ../common/services/mariadb.nix
    ../common/services/nextcloud.nix
    ../common/services/nginx.nix
    ../common/services/openvpn.nix
    ../common/services/ssh.nix
    ../common/services/syncthing.nix
  ];

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;

  networking.enableIPv6 = true;
  networking.useDHCP = true;

  system.stateVersion = "22.11"; # Did you read the comment?
}
