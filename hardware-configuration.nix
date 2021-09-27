{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ata_piix" "ahci" "xhci_pci" "firewire_ohci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/a02220dc-f143-44dd-adf0-de6b2db3e4b7";
      fsType = "ext4";
    };

  fileSystems."/data1" =
  {
    device = "/dev/disk/by-uuid/9f3ebbcc-8402-4e8d-90be-c33bd1ec65f8";
    fsType = "ext4";
  };

  fileSystems."/data2" =
  {
    device = "/dev/disk/by-uuid/6267ddf6-ce97-4d26-9da9-f3e4b96d7fb2";
    fsType = "ext4";
  };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/90af3f02-8d42-4796-8637-8c9f9a8fc23c"; }
    ];

}
