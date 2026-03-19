{
  config,
  self,
  ...
}: {
  sops.secrets."harmonia-signing-key" = {
    sopsFile = self.outPath + "/secrets/harmonia-signing-key";
    format = "binary";
    owner = "harmonia";
  };

  services.harmonia = {
    enable = true;
    signKeyPaths = [config.sops.secrets."harmonia-signing-key".path];
    settings.priority = 35;
  };

  networking.firewall.allowedTCPPorts = [5000];

  # sign all locally built paths via the nix daemon
  nix.settings.secret-key-files = [config.sops.secrets."harmonia-signing-key".path];
}
