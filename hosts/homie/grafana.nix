{
  config,
  self,
  pkgs,
  ...
}: let
  r = config.registry;
  grafanaFqdn = "${r.services.grafana.subdomain}.${r.domain}";
in {
  sops.secrets."grafana-secret-key" = {
    sopsFile = self.outPath + "/secrets/grafana-secret-key";
    format = "binary";
    owner = "grafana";
  };

  services.grafana = {
    enable = true;
    # grafana-clock-panel: used by the "Now" widget on the UniFi-Poller UAP board.
    declarativePlugins = [pkgs.grafanaPlugins.grafana-clock-panel];
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        root_url = "https://${grafanaFqdn}";
      };
      security.secret_key = "$__file{${config.sops.secrets."grafana-secret-key".path}}";
      # Escape special characters (e.g. parentheses in the "Default (default)"
      # UniFi site name) in Prometheus/VictoriaMetrics label-value regex matchers
      # the PromQL-safe way. Without this, `site_name=~"$Site"` interpolates to an
      # invalid escape and every templated query returns no data.
      feature_toggles.prometheusSpecialCharsInLabelValues = true;
    };
    # Declaratively provision the Nix-managed dashboards (currently the WAN
    # "Network Health" board). allowUiUpdates keeps them editable in the UI; the
    # committed JSON stays the source of truth and is re-applied on rebuild.
    provision = {
      enable = true;
      dashboards.settings.providers = [
        {
          name = "nix-dashboards";
          folder = "Networking";
          folderUid = "af4m65ehnlpmod";
          allowUiUpdates = true;
          options.path = ./dashboards;
        }
      ];
    };
  };
  services.nginx.virtualHosts.${grafanaFqdn} = {
    enableACME = true;
    forceSSL = true;
    http3 = true;
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
