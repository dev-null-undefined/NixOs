{pkgs, ...}: let
  domain = "cloud.dev-null.me";
in {
  imports = [./mariadb.nix ./nginx.nix];

  services = {
    nextcloud = {
      package = pkgs.nextcloud25;
      enable = true;
      hostName = domain;
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
        extraTrustedDomains = ["cloud.dev-null.me"];
      };
    };
    mysql = {
      ensureDatabases = ["nextcloud"];
      ensureUsers = [
        {
          name = "nextcloud";
          ensurePermissions = {"nextcloud.*" = "ALL PRIVILEGES";};
        }
      ];
    };
    nginx = {
      # Setup Nextcloud virtual host to listen on ports
      virtualHosts = {
        ${domain} = {
          ## Force HTTP redirect to HTTPS
          forceSSL = true;
          ## LetsEncrypt
          enableACME = true;
          http3 = true;
        };
      };
    };
  };
}
