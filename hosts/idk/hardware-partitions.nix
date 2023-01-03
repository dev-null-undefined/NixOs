{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [./windows-mount.nix];

  boot.initrd.availableKernelModules = ["xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = ["dm-snapshot" "vfat" "nls_cp437" "nls_iso8859-1" "usbhid"];
  boot.supportedFilesystems = ["btrfs"];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/e30bc2fa-9659-48fa-b2cd-63aed5f21d0b";
    fsType = "btrfs";
    options = ["subvol=/root" "compress=zstd"];
  };

  fileSystems."/root/btrfs-top-lvl" = {
    device = "/dev/disk/by-uuid/e30bc2fa-9659-48fa-b2cd-63aed5f21d0b";
    fsType = "btrfs";
    options = ["subvol=/" "compress=zstd"];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/e30bc2fa-9659-48fa-b2cd-63aed5f21d0b";
    fsType = "btrfs";
    options = ["subvol=/home" "compress=zstd"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/e30bc2fa-9659-48fa-b2cd-63aed5f21d0b";
    fsType = "btrfs";
    options = ["subvol=/nix" "compress=zstd" "noatime"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2361-D986";
    fsType = "vfat";
  };

  swapDevices = [{device = "/dev/disk/by-uuid/7d756693-f6f4-49d4-8498-125df0c61821";}];

  boot.initrd.luks.devices.root = {
    device = "/dev/disk/by-uuid/03bb5db4-798c-4931-9ceb-c1628dbdb6a4";
    preLVM = true;
  };

  boot.loader = {
    grub = {
      enable = true;
      version = 2;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
      enableCryptodisk = true;
      saveDefault = true;
    };
    efi.canTouchEfiVariables = true;
  };
}
