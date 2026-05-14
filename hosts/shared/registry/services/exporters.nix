{
  registry.services = {
    adguard-exporter = {
      host = "homie";
      port = 9712;
    };
    jellyfin-exporter = {
      host = "homie";
      port = 9711;
    };
    sonarr-exporter = {
      host = "homie";
      port = 9709;
    };
    radarr-exporter = {
      host = "homie";
      port = 9710;
    };
    node-exporter-oracle = {
      host = "oracle-server";
      port = 9100;
    };
    node-exporter-prosek = {
      host = "prosek-wagner";
      port = 9100;
    };
    node-exporter-brnikov = {
      host = "brnikov";
      port = 9100;
    };
  };
}
