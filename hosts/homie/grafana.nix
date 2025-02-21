{config, ...}: {
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        root_url = "https://grafana.dev-null.me";
      };
    };
  };
  services.nginx.virtualHosts."grafana.dev-null.me" = {
    locations."/" = {
      proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${
        toString config.services.grafana.settings.server.http_port
      }";
      proxyWebsockets = true;
    };
    extraConfig = ''
      access_log  /var/log/nginx/access.log  main;
    '';
  };
}
