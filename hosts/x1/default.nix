# Help is available in the default.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  lib,
  inputs,
  pkgs,
  config,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-13th-gen

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

  generated.network-manager.network-profiles.vpn.cdn77 = {
    enable = true;
    address = "10.0.4.173";
    privateKeySuffix = "_X1";
  };

  documentation.man.generateCaches = false;

  # nix.settings.max-jobs = 5;

  services = {
    # Allows for updating firmware via `fwupdmgr`.
    fwupd.enable = true;
    fprintd.enable = true;
  };

  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };

  systemd.services.ModemManager = {
    enable = true;
    wantedBy = [
      "multi-user.target"
      "network.target"
    ];
  };

  services.tlp.extraConfig = ''
    START_CHARGE_THRESH_BAT0=75
    STOP_CHARGE_THRESH_BAT0=85
    CPU_SCALING_GOVERNOR_ON_BAT=powersave
    ENERGY_PERF_POLICY_ON_BAT=powersave
  '';

  networking.modemmanager.enable = true;

  networking.modemmanager.fccUnlockScripts = [
    {
      id = "1eac:1007";
      path = "${pkgs.modemmanager}/share/ModemManager/fcc-unlock.available.d/1eac";
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
