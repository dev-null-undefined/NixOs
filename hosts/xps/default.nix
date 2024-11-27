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
    # inputs.nixos-hardware.nixosModules.dell-xps-15-9570-intel
    # inputs.nixos-hardware.nixosModules.dell-xps-15-9570-nvidia
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime

    ./yubikey/yubikey.nix
    ./hardware-configuration.nix
  ];

  nix.settings.max-jobs = 5;

  services = {
    # Allows for updating firmware via `fwupdmgr`.
    fwupd.enable = true;

    fprintd.enable = true;

    xserver = {
      videoDrivers = ["nvidia" "intel"];
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

  generated = {
    network-manager.enable = true;
    plymouth.enable = true;
    de.hyprland.enable = lib.mkDefault true;
    services = {
      syncthing.enable = true;
      opensnitch.enable = true;
      #mariadb.enable = true;
    };
    packages.gui = {
      virtual-box.enable = false;
      browsers.all.enable = true;
      mathematica.enable = false;
    };
    packages.work.enable = true;
  };

  documentation.man.generateCaches = false;

  #  specialisation = {
  #    gnome.configuration = {
  #      generated.de = {
  #        gnome.enable = true;
  #        hyprland.enable = false;
  #      };
  #    };
  #    dwm.configuration = {
  #      generated.de = {
  #        dwm.enable = true;
  #        hyprland.enable = false;
  #      };
  #    };
  #    i3.configuration = {
  #      generated.de = {
  #        i3.enable = true;
  #        hyprland.enable = false;
  #      };
  #    };
  #    plasma.configuration = {
  #      generated.de = {
  #        plasma.enable = true;
  #        hyprland.enable = false;
  #      };
  #    };
  #  };

  #  boot.extraModprobeConfig =
  #    "options nvidia "
  #    + lib.concatStringsSep " " [
  #      # nvidia assume that by default your CPU does not support PAT,
  #      # but this is effectively never the case in 2023
  #      "NVreg_UsePageAttributeTable=1"
  #      # This may be a noop, but it's somewhat uncertain
  #      "NVreg_EnablePCIeGen3=1"
  #      # This is sometimes needed for ddc/ci support, see
  #      # https://www.ddcutil.com/nvidia/
  #      #
  #      # Current monitor does not support it, but this is useful for
  #      # the future
  #      "NVreg_RegistryDwords=RMUseSwI2c=0x01;RMI2cSpeed=100"
  #      # When (if!) I get another nvidia GPU, check for resizeable bar
  #      # settings
  #    ];
  #
  #  # Replace a glFlush() with a glFinish() - this prevents stuttering
  #  # and glitching in all kinds of circumstances for the moment.
  #  #
  #  # Apparently I'm waiting for "explicit sync" support, which needs to
  #  # land as a wayland thing. I've seen this work reasonably with VRR
  #  # before, but emacs continued to stutter, so for now this is
  #  # staying.
  #  nixpkgs.overlays = [
  #    (_: final: {
  #      wlroots_0_16 = final.wlroots_0_16.overrideAttrs (_: {
  #        patches = [
  #          ./wlroots-nvidia.patch
  #          ./wlroots-screenshare.patch
  #        ];
  #      });
  #    })
  #  ];

  #custom.wireguard.ips = ["10.100.0.3/24"];

  # networking.firewall.enable = false;

  #documentation.nixos.includeAllModules = false;

  systemd.sleep.extraConfig = "HibernateDelaySec=1h";

  networking.hostId = "69faa161";

  networking.firewall.checkReversePath = "loose";

  system.stateVersion = "23.11"; # Did you read the comment?

  boot = {
    blacklistedKernelModules = ["i2c_hid"];
    # blacklistedKernelModules = ["i2c_hid" "i2c_hid_acpi" "psmouse"];
    # blacklistedKernelModules = ["psmouse"];
    # kernelModules = ["synaptics_i2c"];

    # kernelPackages = pkgs.linuxPackages_latest; #latest kernel doesn't work with nvidia proprietery driver

    # Air plane mode fix
    kernelParams = [
      "acpi_osi=!"
      ''acpi_osi="Windows 2020"''
      "nvidia-drm.fbdev=1"
      "acpi_backlight=native"
      # "i8042.reset"
      # "i8042.nomux"
      #"i8042.nopnp"
      #"i8042.noloop"
      # "i8042.nopnp=1"

      # Force S3 sleep mode. See README.wiki for details.
      "mem_sleep_default=deep"
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

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

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
    nvidia = let
      rcu_patch = pkgs.fetchpatch {
        url = "https://github.com/gentoo/gentoo/raw/c64caf53/x11-drivers/nvidia-drivers/files/nvidia-drivers-470.223.02-gpl-pfn_valid.patch";
        hash = "sha256-eZiQQp2S/asE7MfGvfe6dA/kdCvek9SYa/FFGp24dVg=";
      };

      nv-pack-535 = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "535.154.05";
        sha256_64bit = "sha256-fpUGXKprgt6SYRDxSCemGXLrEsIA6GOinp+0eGbqqJg=";
        sha256_aarch64 = "sha256-G0/GiObf/BZMkzzET8HQjdIcvCSqB1uhsinro2HLK9k=";
        openSha256 = "sha256-wvRdHguGLxS0mR06P5Qi++pDJBCF8pJ8hr4T8O6TJIo=";
        settingsSha256 = "sha256-9wqoDEWY4I7weWW05F4igj1Gj9wjHsREFMztfEmqm10=";
        persistencedSha256 = "sha256-d0Q3Lk80JqkS1B54Mahu2yY/WocOqFFbZVBh+ToGhaE=";

        patches = [rcu_patch];
      };

      nv-pack-550 = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "550.40.07";
        sha256_64bit = "sha256-KYk2xye37v7ZW7h+uNJM/u8fNf7KyGTZjiaU03dJpK0=";
        sha256_aarch64 = "sha256-AV7KgRXYaQGBFl7zuRcfnTGr8rS5n13nGUIe3mJTXb4=";
        openSha256 = "sha256-mRUTEWVsbjq+psVe+kAT6MjyZuLkG2yRDxCMvDJRL1I=";
        settingsSha256 = "sha256-c30AQa4g4a1EHmaEu1yc05oqY01y+IusbBuq+P6rMCs=";
        persistencedSha256 = "sha256-11tLSY8uUIl4X/roNnxf5yS2PQvHvoNjnd2CB67e870=";

        patches = [rcu_patch];
      };

      nv-pack-555 = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "555.42.02";
        sha256_64bit = "sha256-k7cI3ZDlKp4mT46jMkLaIrc2YUx1lh1wj/J4SVSHWyk=";
        sha256_aarch64 = "sha256-rtDxQjClJ+gyrCLvdZlT56YyHQ4sbaL+d5tL4L4VfkA=";
        openSha256 = "sha256-rtDxQjClJ+gyrCLvdZlT56YyHQ4sbaL+d5tL4L4VfkA=";
        settingsSha256 = "sha256-rtDxQjClJ+gyrCLvdZlT56YyHQ4sbaL+d5tL4L4VfkA=";
        persistencedSha256 = "";
      };
    in {
      # package = config.boot.kernelPackages.nvidiaPackages.beta;
      # package = nv-pack-555;

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

      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of
      # supported GPUs is at:
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
      # Only available from driver 515.43.04+
      # Currently alpha-quality/buggy, so false is currently the recommended setting.
      open = true;

      # Enable the Nvidia settings menu,
      # accessible via `nvidia-settings`.
      nvidiaSettings = true;

      # Optionally, you may need to select the appropriate driver version for your specific GPU.

      prime = {
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };
}
