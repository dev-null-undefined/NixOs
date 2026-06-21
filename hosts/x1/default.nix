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
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-13th-gen

    ./hardware-configuration.nix
  ];

  generated = {
    network-manager.enable = true;
    plymouth.enable = true;
    de.hyprland.enable = lib.mkDefault true;
    hardware.thinkpad.enable = true;
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

  generated.network-manager.network-profiles.vpn.cdn77 = {
    enable = true;
    address = "10.0.4.173";
    privateKeySuffix = "_X1";
  };

  generated.network-manager.network-profiles.gsm.o2-cz.enable = true;

  documentation.man.cache.enable = false;

  nix.settings.max-jobs = 0; # offload all builds to homie

  services = {
    # btrfs root is mounted with discard=async (continuous trim);
    # periodic fstrim is redundant and FITRIM fails on btrfs+async-discard.
    fstrim.enable = false;

    # thermald cannot run on Lunar Lake (logs: "Unsupported cpu model or platform")
    # and exits immediately on every boot.
    thermald.enable = false;
  };

  # Plymouth implicitly enables console.earlySetup; the initrd-stage setfont
  # cannot resolve Lat2-Terminus16 (KBD_FONT_DIR isn't set on the unit), producing
  # boot-log errors. Post-boot vconsole-setup exits cleanly without setting a font.
  console.earlySetup = lib.mkForce false;

  systemd.services.fprintd = {
    wantedBy = ["multi-user.target"];
    serviceConfig.Type = "simple";
  };

  systemd.services.ModemManager = {
    enable = true;
    wantedBy = [
      "multi-user.target"
      "network.target"
    ];
  };

  networking.modemmanager.enable = true;

  networking.modemmanager.fccUnlockScripts = [
    {
      id = "1eac:1007";
      path = "${pkgs.modemmanager}/share/ModemManager/fcc-unlock.available.d/1eac:1007";
    }
  ];

  networking = {
    hostId = "d214e92c";
    firewall.checkReversePath = "loose";
  };

  hardware.ipu6 = {
    enable = true;
    platform = "ipu6epmtl";
  };

  boot = {
    initrd.kernelModules = ["usbio" "gpio_usbio" "i2c_usbio"];

    resumeDevice = "/dev/disk/by-uuid/a2ac4f11-cef2-411d-92af-1911aa165d32";

    # kernelPackages = pkgs.linuxPackages_latest; # latest kernel doesn't work with nvidia proprietery driver

    loader = {
      grub = {
        # Bootloader.
        enable = true;
        efiSupport = true;
        device = "nodev";
        useOSProber = true;
        saveDefault = true;
      };
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
    };
  };

  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    lidSwitchExternalPower = "suspend-then-hibernate";
  };

  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "4h";
    HibernateMode = "shutdown";
    HibernateOnACPower = false;
  };

  services.tlp.settings = {
    USB_AUTOSUSPEND = 1;
    PCIE_ASPM_ON_BAT = "powersupersave";
    WIFI_PWR_ON_BAT = "on";
    RUNTIME_PM_ON_BAT = "auto";
    NMI_WATCHDOG = 0;

    PLATFORM_PROFILE_ON_BAT = "low-power";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
    CPU_MAX_PERF_ON_BAT = 70;
    DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE = "bluetooth";
  };

  generated.hardware.wakeup-trim = {
    enable = true;
    pciDevices = {
      "0000:00:14.0" = "Arrow Lake xHCI USB 3.2 controller";
      "0000:00:0d.0" = "Thunderbolt 4 USB controller";
      "0000:00:0d.2" = "Thunderbolt 4 NHI #0";
      "0000:00:0d.3" = "Thunderbolt 4 NHI #1";
      "0000:00:07.0" = "Thunderbolt 4 PCIe Root Port #0";
      "0000:00:07.2" = "Thunderbolt 4 PCIe Root Port #2";
      # Quectel RM520N-GL WWAN modem — cellular paging wakes the laptop from s2idle.
      "0000:00:1c.6" = "PCIe Root Port #7 (WWAN modem upstream)";
      "0000:08:00.0" = "Quectel RM520N-GL 5G WWAN modem";
    };
    mhiDevices.mhi0 = "Modem Host Interface (Quectel WWAN)";
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

  system.stateVersion = "25.05"; # Did you read the comment?
}
