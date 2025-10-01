{
  self,
  lib,
  config,
  ...
}: {
  generated.network-manager.network-profiles = {
    wifi.enable = lib.mkDefault true;
  };

  sops.secrets."network-manager.env" = {
    sopsFile = self.outPath + "/secrets/network-manager.env";
    format = "dotenv";
  };

  networking.networkmanager.ensureProfiles.environmentFiles = [config.sops.secrets."network-manager.env".path];
}
