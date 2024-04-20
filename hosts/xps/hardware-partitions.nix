{...}: let
  lvmRoot = "981b02c2-2bd6-44b7-8940-4dcf309e7c46";
in {
  boot = {
    supportedFilesystems = ["btrfs"];

    initrd = {
      availableKernelModules = ["xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod"];
      kernelModules = ["dm-snapshot" "vfat" "nls_cp437" "nls_iso8859-1" "usbhid"];

      luks.devices = {
        root = {
	  device = "/dev/disk/by-uuid/262fb0d6-293f-4520-8c54-e4d05e09daea";
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
      device = "/dev/disk/by-uuid/1B97-4322";
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

    "/nix" = {
      device = "/dev/disk/by-uuid/${lvmRoot}";
      fsType = "btrfs";
      options = ["subvol=/nix" "compress=zstd" "noatime"];
    };

    "/home" = {
      device = "/dev/disk/by-uuid/${lvmRoot}";
      fsType = "btrfs";
      options = ["subvol=/home" "compress=zstd"];
    };
  };

  swapDevices = [{device = "/dev/disk/by-uuid/68694017-24c1-4e95-8441-2b1f45d7828c";}];

  hardware.cpu.intel.updateMicrocode = true;
}
