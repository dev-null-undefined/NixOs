# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{...}: {
  generated = {
    enable = true;
    services = {
      ssh = {
        enable = true;
        presentation.enable = true;
      };
    };
  };

  domain = "dev-null.me";

  documentation.man.generateCaches = false;

  networking.firewall.enable = false;
  networking.firewall.allowPing = true;

  networking.enableIPv6 = true;
  networking.useDHCP = true;

  system.stateVersion = "22.11"; # Did you read the comment?
}
