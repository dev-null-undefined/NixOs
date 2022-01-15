{ pkgs, ... }:

let
    stable = import <nixos-stable> { config = { allowUnfree = true; }; };
in
{
  networking.firewall.allowedTCPPorts = [ 80 ];
  services.nextcloud = {
    package = pkgs.nextcloud23; 
    enable = true;
    hostName = "nextcloud";
    # https = true;
    home = "/data1/nextcloud";
    caching = {
      apcu = true;
      redis = false;
      memcached = true;
    };
    config = {
      dbtype = "mysql";
      dbname = "nextcloud";
      dbuser = "nextcloud";
      dbhost = "127.0.0.1";
      dbport = 3306;
      dbpassFile = "/var/nextcloud-db-pass";
      adminpassFile = "/var/nextcloud-admin-pass";
      extraTrustedDomains = [ "192.168.0.170" ];
    };
  };
}
