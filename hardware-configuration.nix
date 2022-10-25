{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix") ./windows-mount.nix ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "v4l2loopback" "ec_sys" ];
  boot.extraModulePackages = with config.boot.kernelPackages;
    [ v4l2loopback.out ];

  # Air plane mode fix
  boot.kernelParams = [ "acpi_osi=!" ''acpi_osi="Windows 2006"'' ];

  boot.extraModprobeConfig = ''
    # exclusive_caps: Skype, Zoom, Teams etc. will only show device when actually streaming
    # card_label: Name of virtual camera, how it'll show up in Skype, Zoom, Teams
    # https://github.com/umlaeute/v4l2loopback
    options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"
    options ec_sys write_support=1
    options nvidia_drm modeset=1
  '';

  # C perf debugging variables
  boot.kernel.sysctl = {
    "kernel.perf_event_paranoid" = true;
    "kernel.kptr_restrict" = false;
  };

  # lid close action
  services.logind.lidSwitch = "ignore";
  services.logind.lidSwitchDocked = "ignore";
  services.logind.extraConfig = "HandleLidSwitch=ignore";

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/feee7f36-8bcc-4d80-8626-086896503105";
    fsType = "ext4";
  };
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/8d7d4e81-0760-4650-b847-5aa472286c09";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/DA0A-EAB3";
    fsType = "vfat";
  };

  swapDevices = [{ device = "/dev/nvme1n1p2"; }];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
