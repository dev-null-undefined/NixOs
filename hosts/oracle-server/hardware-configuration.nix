{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/profiles/qemu-guest.nix") ./hardware-partitions.nix ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "virtio_pci" "usbhid" ];
  boot.initrd.kernelModules = [ ];
  boot.initrd.includeDefaultModules = false; # Fix for missing i915 module
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
