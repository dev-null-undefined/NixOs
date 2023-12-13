# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  lib,
  inputs,
  ...
}: {
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-base.nix"
    ./gpg-guide.nix
  ];

  generated = {
    secure.enable = true;
    airgapped.enable = true;

    services.ssh.enable = true;

    packages = {
      development.enable = false;
      development.include.enable = true;
      gui = {
        enable = false;
        browsers.enable = true;
        gparted.enable = true;
        file-managers.enable = true;
        terminals.enable = true;
      };
    };

    de.gnome.enable = lib.mkDefault true;
    nvidia.nvidia-sync.enable = false;
    nvidia.nvidia-offload.enable = false;
  };

  documentation.man.generateCaches = false;

  system.stateVersion = "22.11"; # Did you read the comment?
}
