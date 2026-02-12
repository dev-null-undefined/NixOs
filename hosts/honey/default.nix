# Help is available in the default.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  lib,
  inputs,
  pkgs,
  config,
  ...
}: {
  imports = [./hardware-configuration.nix];

  generated = {
    network-manager.enable = true;
    plymouth.enable = true;
    de.hyprland.enable = lib.mkDefault true;
    services = {
      ssh.enable = true;
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

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };

  generated.network-manager.network-profiles.vpn.cdn77 = {
    enable = true;
    address = "10.0.3.248";
    privateKeySuffix = "_PC";
  };

  # custom.wireguard.ips = ["10.100.0.5/24"];

  documentation.man.generateCaches = false;

  # nix.settings.max-jobs = 5;

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  services = {
    # Allows for updating firmware via `fwupdmgr`.
    fwupd.enable = true;

    xserver = {
      videoDrivers = [
        "nvidia"
        "modesetting"
      ];
    };
  };

  systemd.sleep.extraConfig = "HibernateDelaySec=1h";

  networking = {
    hostId = "d765d516";
    firewall.checkReversePath = "loose";
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest; # latest kernel doesn't work with nvidia proprietery driver

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    loader = {
      systemd-boot = {
        enable = false;
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
      modesetting.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
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
    };
  };

  system.stateVersion = "24.11"; # Did you read the comment?
}
