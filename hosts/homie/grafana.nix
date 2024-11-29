{config, ...}: {
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
      };
    };
  };
  services.nginx.virtualHosts."_" = {
    default = true;
    locations."/" = {
      proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${
        toString config.services.grafana.settings.server.http_port
      }";
      proxyWebsockets = true;
    };
  };
}
