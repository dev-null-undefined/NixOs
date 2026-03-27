{
  config,
  self,
  ...
}: {
  sops.secrets."tailscale-exporter.env" = {
    sopsFile = self.outPath + "/secrets/tailscale-exporter.env";
    format = "dotenv";
    key = "";
  };

  services.prometheus.exporters.tailscale = {
    enable = true;
    environmentFile = config.sops.secrets."tailscale-exporter.env".path;
  };
}
