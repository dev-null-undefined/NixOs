{
  config,
  self,
  ...
}: {
  sops.secrets."unifi-prometheus-pass" = {
    sopsFile = self.outPath + "/secrets/unifi-prometheus-pass";
    format = "binary";
    owner = "unpoller-exporter";
  };

  services.prometheus.exporters.unpoller = {
    enable = true;
    controllers = [
      {
        user = "prometheus";
        pass = config.sops.secrets."unifi-prometheus-pass".path;
        url = "https://127.0.0.1:${toString config.registry.services.unifi.port}";
        verify_ssl = false;
      }
    ];
  };
}
