{...}: let
  lvmRoot = "aafcdb75-314b-4332-87ad-391bde3d2091";
  homeRoot = "a42e47df-39e9-4290-bb1a-383131c73c4e";
in {
  imports = [./windows-mount.nix];

  boot = {
    supportedFilesystems = ["btrfs"];

    initrd = {
      availableKernelModules = ["xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod"];
      kernelModules = ["dm-snapshot" "vfat" "nls_cp437" "nls_iso8859-1" "usbhid"];

      luks.devices = {
        root = {
          device = "/dev/disk/by-uuid/2e0eeb5d-bd42-471b-93c0-768b12d9b66e";
        };
        home = {
          device = "/dev/disk/by-uuid/4fd380c7-aeb6-4534-b786-02f95de78664";
        };
      };
    };

    loader = {
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        useOSProber = true;
        enableCryptodisk = true;
        saveDefault = true;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/D5CD-12F4";
      fsType = "vfat";
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/${lvmRoot}";
      fsType = "btrfs";
      options = ["subvol=/root" "compress=zstd"];
    };

    "/root/btrfs-top-lvl/root" = {
      device = "/dev/disk/by-uuid/${lvmRoot}";
      fsType = "btrfs";
      options = ["subvol=/" "compress=zstd"];
    };

    "/old-home" = {
      device = "/dev/disk/by-uuid/${lvmRoot}";
      fsType = "btrfs";
      options = ["subvol=/home" "compress=zstd"];
    };

    "/nix" = {
      device = "/dev/disk/by-uuid/${lvmRoot}";
      fsType = "btrfs";
      options = ["subvol=/nix" "compress=zstd" "noatime"];
    };
  };

  fileSystems = {
    "/root/btrfs-top-lvl/home" = {
      device = "/dev/disk/by-uuid/${homeRoot}";
      fsType = "btrfs";
      options = ["subvol=/" "compress=zstd"];
    };

    "/home" = {
      device = "/dev/disk/by-uuid/${homeRoot}";
      fsType = "btrfs";
      options = ["subvol=/home" "compress=zstd"];
    };
  };

  swapDevices = [{device = "/dev/disk/by-uuid/8cb7bcbe-38c1-447d-a30e-93cb24875bbf";}];

  hardware.cpu.intel.updateMicrocode = true;
}
