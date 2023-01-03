{
  pkgs,
  lib,
  ...
}: {
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    dataDir = "/var/lib/mysql";
  };
}
