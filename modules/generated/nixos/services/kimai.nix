{
  config,
  lib,
  ...
}: let
  kimai-domain = "${config.registry.services.kimai.subdomain}.${config.domain}";
in {
  generated = {
    # mkDefault so we don't clash with nextcloud's identical assignments.
    services.mariadb.enable = lib.mkDefault true;
    services.nginx.enable = lib.mkDefault true;
  };

  services.kimai.sites.${kimai-domain} = {
    database.createLocally = true;
    # createLocally sets up unix_socket (peer) auth, but the default
    # DATABASE_URL uses TCP, which that auth rejects. Point at the socket
    # so DATABASE_URL gets `&unixSocket=...`.
    database.socket = "/run/mysqld/mysqld.sock";
  };

  # The kimai module sets the vhost + PHP-FPM root but no TLS; add it here.
  services.nginx.virtualHosts.${kimai-domain} = {
    forceSSL = true;
    enableACME = true;
    http3 = true;
  };
}
