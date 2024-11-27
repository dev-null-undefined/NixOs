{...}: let
  root = "18527a28-5247-4d36-b8d8-63b086317b81";
in {
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/${root}";
    fsType = "btrfs";
    options = ["subvol=root" "compress=zstd"];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/${root}";
    fsType = "btrfs";
    options = ["subvol=home" "compress=zstd"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/${root}";
    fsType = "btrfs";
    options = ["subvol=nix" "noatime" "compress=zstd"];
  };

  fileSystems."/var/data" = {
    device = "/dev/disk/by-uuid/640bd80d-0c99-447d-81b9-8ec168ea43f8";
    fsType = "btrfs";
    options = ["subvol=data" "noatime" "compress=zstd"];
  };

  swapDevices = [{device = "/dev/disk/by-uuid/b430b9b3-5bb7-435f-890e-b3f3695a8256";}];

  boot.loader.grub = {
    enable = true;
    device = "/dev/disk/by-id/wwn-0x5002538e3054aa55";
  };
}
