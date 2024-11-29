{
  services.prometheus.exporters.nextcloud = {
    enable = true;
    user = "nextcloud";
    url = "https://homie.rat-python.ts.net";
    tokenFile = "/var/nextcloud-token";
  };
}
