{ pkgs, ... }:

{
  imports = [ ./mariadb.nix ];

  networking.firewall.allowedTCPPorts = [ 80 ];
  services.nextcloud = {
    package = pkgs.nextcloud25;
    enable = true;
    hostName = "cloud.dev-null.me";
    https = true;
    home = "/nextcloud";
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
      extraTrustedDomains = [ "cloud.dev-null.me" ];
    };
  };

  services.mysql = {
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [{
      name = "nextcloud";
      ensurePermissions = { "nextcloud.*" = "ALL PRIVILEGES"; };
    }];
  };
}
