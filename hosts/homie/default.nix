# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{...}: {
  imports = [./router.nix];

  generated.services = {
    ssh.enable = true;
    nextcloud.enable = true;
    unifi-docker.enable = true;
  };

  documentation.man.generateCaches = false;

  services = {
    nextcloud = {
      https = false;
      appstoreEnable = true;
      home = "/var/data/nextcloud";
      settings.trusted_domains = ["192.168.2.1"];
    };
  };

  system.stateVersion = "22.11"; # Did you read the comment?
}
