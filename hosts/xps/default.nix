# Help is available in the default.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  lib,
  inputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    #inputs.nixos-hardware.nixosModules.dell-xps-15-9570-intel
    inputs.nixos-hardware.nixosModules.dell-xps-15-9570-nvidia
    ./yubikey/yubikey.nix
  ];

  generated = {
    network-manager.enable = true;
    plymouth.enable = true;
    de.hyprland.enable = lib.mkDefault true;
    services = {
      syncthing.enable = true;
      opensnitch.enable = true;
      #mariadb.enable = true;
    };
    packages.gui.virtual-box.enable = false;
    packages.gui.browsers.all.enable = true;
    packages.gui.mathematica.enable =
      false;
  };
  hardware.nvidia = {
    prime.offload.enable = lib.mkForce false;
    prime.offload.enableOffloadCmd = lib.mkForce false;
    prime.sync.enable = lib.mkForce true;
  };

  specialisation = {
    gnome.configuration = {
      generated.de = {
        gnome.enable = true;
        hyprland.enable = false;
      };
    };
  };

  boot.kernelParams = ["nvidia.NVreg_PreserveVideoMemoryAllocations=1"];

  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.powerManagement.finegrained = true;
  hardware.nvidia.nvidiaSettings = true;
  hardware.nvidia.modesetting.enable = true;

  # Making sure to use the proprietary drivers until the issue above is fixed upstream
  hardware.nvidia.open = false;
  boot.extraModprobeConfig =
    "options nvidia "
    + lib.concatStringsSep " " [
      # nvidia assume that by default your CPU does not support PAT,
      # but this is effectively never the case in 2023
      "NVreg_UsePageAttributeTable=1"
      # This may be a noop, but it's somewhat uncertain
      "NVreg_EnablePCIeGen3=1"
      # This is sometimes needed for ddc/ci support, see
      # https://www.ddcutil.com/nvidia/
      #
      # Current monitor does not support it, but this is useful for
      # the future
      "NVreg_RegistryDwords=RMUseSwI2c=0x01;RMI2cSpeed=100"
      # When (if!) I get another nvidia GPU, check for resizeable bar
      # settings
    ];

  nixpkgs.overlays = [
    (_: final: {
      wlroots_0_16 = final.wlroots_0_16.overrideAttrs (_: {
        patches = [
          ./wlroots-nvidia.patch
          ./wlroots-screenshare.patch
        ];
      });
    })
  ];

  #custom.wireguard.ips = ["10.100.0.3/24"];

  # networking.firewall.enable = false;

  documentation.man.generateCaches = false;
  #documentation.nixos.includeAllModules = false;

  systemd.sleep.extraConfig = "HibernateDelaySec=1h";

  networking.hostId = "69faa161";

  system.stateVersion = "23.11"; # Did you read the comment?
}
