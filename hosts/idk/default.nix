# Help is available in the default.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    inputs.nixos-hardware.nixosModules.msi-gs60
    ./yubikey/yubikey.nix
  ];

  generated = {
    network-manager.enable = true;
    de.hyprland.enable = true;
    plymouth.enable = true;
    services = {
      syncthing.enable = true;
      mariadb.enable = true;
    };
  };

  systemd.sleep.extraConfig = "HibernateDelaySec=1h";

  networking.hostId = "69faa160";

  system.stateVersion = "22.11"; # Did you read the comment?
}
