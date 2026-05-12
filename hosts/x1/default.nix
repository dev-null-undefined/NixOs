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

  documentation.man.cache.enable = false;

  nix.settings.max-jobs = 0; # offload all builds to homie

  services = {
    # Allows for updating firmware via `fwupdmgr`.
    fwupd.enable = true;

    # btrfs root is mounted with discard=async (continuous trim);
    # periodic fstrim is redundant and FITRIM fails on btrfs+async-discard.
    fstrim.enable = false;
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
    HibernateDelaySec = "2h";
    HibernateMode = "shutdown";
  };

  services.tlp.settings = {
    USB_AUTOSUSPEND = 1;
    PCIE_ASPM_ON_BAT = "powersupersave";
    WIFI_PWR_ON_BAT = "on";
    RUNTIME_PM_ON_BAT = "auto";
    NMI_WATCHDOG = 0;
  };

  # Trim wakeup sources to reduce spurious S0ix wakes. Lid + power button still
  # wake the system. Re-enable a device if you need wake-on-dock or wake-on-USB.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", KERNEL=="0000:00:14.0", ATTR{power/wakeup}="disabled"
    ACTION=="add", SUBSYSTEM=="pci", KERNEL=="0000:00:0d.0", ATTR{power/wakeup}="disabled"
    ACTION=="add", SUBSYSTEM=="pci", KERNEL=="0000:00:0d.2", ATTR{power/wakeup}="disabled"
    ACTION=="add", SUBSYSTEM=="pci", KERNEL=="0000:00:0d.3", ATTR{power/wakeup}="disabled"
    ACTION=="add", SUBSYSTEM=="pci", KERNEL=="0000:00:07.0", ATTR{power/wakeup}="disabled"
    ACTION=="add", SUBSYSTEM=="pci", KERNEL=="0000:00:07.2", ATTR{power/wakeup}="disabled"
  '';

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
