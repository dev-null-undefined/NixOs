{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot.kernelModules = ["kvm-intel" "v4l2loopback" "ec_sys"];
  boot.extraModulePackages = with config.boot.kernelPackages; [v4l2loopback.out];

  #boot.kernelPackages = pkgs.linuxPackages_latest; #latest kernel doesn't work with nvidia proprietery driver

  hardware.enableAllFirmware = true;

  # Air plane mode fix
  boot.kernelParams = ["acpi_osi=!" ''acpi_osi="Windows 2006"''];

  boot.extraModprobeConfig = ''
    # exclusive_caps: Skype, Zoom, Teams etc. will only show device when actually streaming
    # card_label: Name of virtual camera, how it'll show up in Skype, Zoom, Teams
    # https://github.com/umlaeute/v4l2loopback
    options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"
    options ec_sys write_support=1
    options nvidia_drm modeset=1
  '';

  # lid close action
  services.logind.lidSwitch = "ignore";
  services.logind.lidSwitchDocked = "ignore";
  services.logind.extraConfig = "HandleLidSwitch=ignore";

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  hardware.nvidia.prime = {
    # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
    intelBusId = "PCI:0:2:0";

    # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
    nvidiaBusId = "PCI:1:0:0";
  };

  # Default number of cores to use for building nix derivations
  nix.settings = {
    max-jobs = 6;
  };
}
