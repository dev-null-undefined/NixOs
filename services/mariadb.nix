{ pkgs, ... }:

{
  services.mysql = {
    package = pkgs.stable.mariadb;
    enable = true;
    initialScript = pkgs.writeText "mysql-init" ''
      CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY 'hunter2';
      CREATE DATABASE IF NOT EXISTS nextcloud;
      GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER,
        CREATE TEMPORARY TABLES ON nextcloud.* TO 'nextcloud'@'localhost'
        IDENTIFIED BY 'MDVkMGU2NDVhYTBlMDQxZTJkMjRjNzRm';
      FLUSH privileges;
    '';
  };
}
