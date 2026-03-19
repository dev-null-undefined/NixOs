{
  config,
  self,
  ...
}: {
  sops.secrets."grafana-secret-key" = {
    sopsFile = self.outPath + "/secrets/grafana-secret-key";
    format = "binary";
    owner = "grafana";
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        root_url = "https://grafana.dev-null.me";
      };
      security.secret_key = "$__file{${config.sops.secrets."grafana-secret-key".path}}";
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
