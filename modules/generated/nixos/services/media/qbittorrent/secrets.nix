{
  config,
  self,
  ...
}: let
  cfg = config.generated.services.media.qbittorrent.include;
in {
  sops.secrets."qbittorrent-pass" = {
    sopsFile = self.outPath + "/secrets/qbittorrent-pass";
    format = "binary";
    owner = cfg.user;
  };
}
