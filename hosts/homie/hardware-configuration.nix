{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["uhci_hcd" "ehci_pci" "ata_piix" "ahci" "xhci_pci" "firewire_ohci" "usbhid" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  # boot.initrd.includeDefaultModules = false; # Fix for missing i915 module

  boot.kernelPackages = pkgs.linuxPackages_latest;

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
