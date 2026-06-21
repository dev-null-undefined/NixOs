# Help is available in the default.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  lib,
  inputs,
  pkgs,
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
    nvidia.nvidia-sync.enable = true;
    hardware.fingerprint.enable = true;
    services = {
      distributed-builds.enable = true;
      money-machine.enable = true;
      opencode.enable = true;
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

  services.postgresql.enable = true;

  boot.resumeDevice = "/dev/disk/by-uuid/74ae1745-5dbd-4f6c-ac22-7c1add60c88f";

  systemd.sleep.settings.Sleep.HibernateDelaySec = "1h";

  services.logind.powerKey = "lock";

  custom.wireguard.ips = ["${config.registry.hosts.xps.wgIp}/24"];

  generated.network-manager.network-profiles.vpn.cdn77 = {
    enable = true;
    address = "10.0.4.173";
    privateKeySuffix = "_X1";
  };

  documentation.man.cache.enable = false;

  nix.settings.max-jobs = 0; # offload all builds to homie

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  services = {
    xserver = {
      videoDrivers = [
        "nvidia"
        "modesetting"
      ];
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
    # blacklistedKernelModules = ["i2c_hid" "i2c_hid_acpi" "psmouse"];
    # blacklistedKernelModules = ["psmouse"];
    # kernelModules = ["synaptics_i2c"];

    # kernelPackages = pkgs.stable.linuxPackages_6_12;
    # latest kernel doesn't work with nvidia proprietery driver

    kernelParams = [
      "nvidia-drm.fbdev=1"
      "acpi_backlight=native"

      # https://wiki.hyprland.org/Nvidia/
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"

      # XPS 16 9640: fix Intel Arc GPU random freezes
      "iommu.strict=1"

      # XPS 16 9640 + Hyprland: avoid swiotlb buffer exhaustion via simpledrm
      "initcall_blacklist=simpledrm_platform_driver_init"
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
      # package = config.boot.kernelPackages.nvidiaPackages.latest;
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
      # GSP-RM firmware bug: heartbeat freezes after GC6 exit, causing GPU hang
      # on dock disconnect / display pipeline events. Use proprietary driver
      # and disable runtime PM. GSP itself cannot be disabled on Ada Lovelace
      # with driver 595 (mandatory at hw level; module drops the firmware bundle
      # via `hardware.firmware = optional gsp.enable nvidia_x11.firmware`, which
      # breaks DRM init).
      moduleParams.nvidia.NVreg_DynamicPowerManagement = "0x00";
      nvidiaSettings = true;
      nvidiaPersistenced = true;

      # Optionally, you may need to select the appropriate driver version for your specific GPU.

      prime = {
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };

  system.stateVersion = "23.11"; # Did you read the comment?
}
