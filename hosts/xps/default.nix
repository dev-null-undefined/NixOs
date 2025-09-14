# Help is available in the default.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  lib,
  inputs,
  pkgs,
  config,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime

    ./yubikey/yubikey.nix
    ./hardware-configuration.nix
  ];

  generated = {
    network-manager.enable = true;
    plymouth.enable = true;
    de.hyprland.enable = lib.mkDefault true;
    services = {
      # syncthing.enable = true;
      # opensnitch.enable = true;
      # mariadb.enable = true;
    };
    packages.gui = {
      virtual-box.enable = false;
      browsers.all.enable = true;
      mathematica.enable = false;
    };
    packages.work.enable = true;
  };

  custom.wireguard.ips = ["10.100.0.5/24"];

  documentation.man.generateCaches = false;

  nix.settings.max-jobs = 5;

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  services = {
    # Allows for updating firmware via `fwupdmgr`.
    fwupd.enable = true;

    fprintd.enable = true;

    xserver = {
      videoDrivers = ["nvidia" "modesetting"];
      synaptics.enable = lib.mkForce false;
    };
    thermald.enable = true;
    libinput = {
      enable = true;
      touchpad = {
        tapping = true;
        tappingDragLock = true;
      };
    };
  };

  networking = {
    hostId = "69faa161";
    firewall.checkReversePath = "loose";
  };

  boot = {
    blacklistedKernelModules = ["i2c_hid" "hid_multitouch" "i2c-hid"];
    # blacklistedKernelModules = ["i2c_hid" "i2c_hid_acpi" "psmouse"];
    # blacklistedKernelModules = ["psmouse"];
    # kernelModules = ["synaptics_i2c"];

    # kernelPackages = pkgs.linuxPackages_latest;
    # latest kernel doesn't work with nvidia proprietery driver

    # Air plane mode fix
    kernelParams = [
      "acpi_osi=!"
      ''acpi_osi="Windows 2020"''
      "nvidia-drm.fbdev=1"
      "acpi_backlight=native"
      # Force S3 sleep mode
      "mem_sleep_default=deep"

      # https://wiki.hyprland.org/Nvidia/
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    ];

    loader = {
      grub = {
        # Bootloader.
        enable = true;
        efiSupport = true;
        device = "nodev";

        gfxmodeEfi = "1920x1080";
        fontSize = 36;
      };
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
    };
  };

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "cs_CZ.UTF-8";
    LC_IDENTIFICATION = "cs_CZ.UTF-8";
    LC_MEASUREMENT = "cs_CZ.UTF-8";
    LC_MONETARY = "cs_CZ.UTF-8";
    LC_NAME = "cs_CZ.UTF-8";
    LC_NUMERIC = "cs_CZ.UTF-8";
    LC_PAPER = "cs_CZ.UTF-8";
    LC_TELEPHONE = "cs_CZ.UTF-8";
    LC_TIME = "cs_CZ.UTF-8";
  };

  hardware = {
    nvidia = {
      # package = config.boot.kernelPackages.nvidiaPackages;
      # Modesetting is required.
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      # Enable this if you have graphical corruption issues or application crashes after waking
      # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
      # of just the bare essentials.
      powerManagement.enable = true;

      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;

      # Optionally, you may need to select the appropriate driver version for your specific GPU.

      prime = {
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };

  system.stateVersion = "23.11"; # Did you read the comment?
}
