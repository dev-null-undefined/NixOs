{
  lib,
  inputs,
  ...
}: {
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-base.nix"
    ./gpg-guide.nix
  ];

  # speed up image creation time by using lower compression level
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  generated = {
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

    de.hyprland.enable = lib.mkDefault true;
    nvidia = {
      nvidia-default.enable = true;

      nvidia-sync.enable = false;
      nvidia-offload.enable = false;
    };
  };

  documentation.man.generateCaches = false;

  system.stateVersion = "22.11"; # Did you read the comment?
}
