{
  services.prometheus.exporters.mysqld = {
    enable = true;
    user = "nextcloud";
    configFile = ./mysqld-nextcloud.cnf;
  };
}
