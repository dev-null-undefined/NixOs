{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/cc0038f9-46f9-47d9-a9b8-90e3a0f08536";
    fsType = "btrfs";
    options = ["subvol=root" "compress=zstd"];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/cc0038f9-46f9-47d9-a9b8-90e3a0f08536";
    fsType = "btrfs";
    options = ["subvol=home" "compress=zstd"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/cc0038f9-46f9-47d9-a9b8-90e3a0f08536";
    fsType = "btrfs";
    options = ["subvol=nix" "noatime" "compress=zstd"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/D764-0C6B";
    fsType = "vfat";
  };

  swapDevices = [];

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
  };
}
