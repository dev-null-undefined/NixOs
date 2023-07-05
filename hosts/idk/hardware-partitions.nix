{...}: let
  lvmRoot = "aafcdb75-314b-4332-87ad-391bde3d2091";
in {
  imports = [./windows-mount.nix];

  boot.initrd.availableKernelModules = ["xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = ["dm-snapshot" "vfat" "nls_cp437" "nls_iso8859-1" "usbhid"];
  boot.supportedFilesystems = ["btrfs"];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/${lvmRoot}";
    fsType = "btrfs";
    options = ["subvol=/root" "compress=zstd"];
  };

  fileSystems."/root/btrfs-top-lvl" = {
    device = "/dev/disk/by-uuid/${lvmRoot}";
    fsType = "btrfs";
    options = ["subvol=/" "compress=zstd"];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/${lvmRoot}";
    fsType = "btrfs";
    options = ["subvol=/home" "compress=zstd"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/${lvmRoot}";
    fsType = "btrfs";
    options = ["subvol=/nix" "compress=zstd" "noatime"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/D5CD-12F4";
    fsType = "vfat";
  };

  swapDevices = [{device = "/dev/disk/by-uuid/8cb7bcbe-38c1-447d-a30e-93cb24875bbf";}];

  boot.initrd.luks.devices.root = {
    device = "/dev/disk/by-uuid/2e0eeb5d-bd42-471b-93c0-768b12d9b66e";
    preLVM = true;
  };

  boot.loader = {
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

  hardware.cpu.intel.updateMicrocode = true;
}
