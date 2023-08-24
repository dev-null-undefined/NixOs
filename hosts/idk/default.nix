# Help is available in the default.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  self,
  lib,
  inputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    inputs.nixos-hardware.nixosModules.msi-gs60
    ./yubikey/yubikey.nix
  ];

  generated = {
    network-manager.enable = true;
    plymouth.enable = true;
    de.hyprland.enable = lib.mkDefault true;
    services = {
      syncthing.enable = true;
      #mariadb.enable = true;
    };
    packages.gui.virtual-box.enable = false;
  };

  specialisation = {
    gnome.configuration = {
      generated.de = {
        gnome.enable = true;
        hyprland.enable = false;
      };
    };
    dwm.configuration = {
      generated.de = {
        dwm.enable = true;
        hyprland.enable = false;
      };
    };
    hyprland.configuration = {
      generated.de.hyprland.enable = true;
    };
    sway.configuration = {
      generated.de = {
        sway.enable = true;
        hyprland.enable = false;
      };
    };
  };

  home-manager.users = self.lib'.internal.mkHomeNixOsUser "martin";

  #networking.firewall.enable = false;

  documentation.man.generateCaches = false;
  #documentation.nixos.includeAllModules = false;

  systemd.sleep.extraConfig = "HibernateDelaySec=1h";

  networking.hostId = "69faa160";

  system.stateVersion = "22.11"; # Did you read the comment?
}
