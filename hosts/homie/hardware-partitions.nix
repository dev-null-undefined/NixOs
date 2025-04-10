{...}: let
  root = "2ca089e6-f522-4c43-82c7-ad7f567ab9fa";
in {
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/${root}";
    fsType = "btrfs";
    options = ["subvol=root" "noatime" "compress=zstd"];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/${root}";
    fsType = "btrfs";
    options = ["subvol=home" "noatime" "compress=zstd"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/${root}";
    fsType = "btrfs";
    options = ["subvol=nix" "noatime" "compress=zstd"];
  };

  fileSystems."/swap" = {
    device = "/dev/disk/by-uuid/${root}";
    fsType = "btrfs";
    options = ["subvol=swap"];
  };

  fileSystems."/var/data" = {
    device = "/dev/disk/by-uuid/640bd80d-0c99-447d-81b9-8ec168ea43f8";
    fsType = "btrfs";
    options = ["subvol=data" "noatime" "compress=zstd"];
  };

  swapDevices = [{device = "/swap/swapfile";}];
}
