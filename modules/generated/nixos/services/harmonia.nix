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

  services.harmonia.cache = {
    enable = true;
    signKeyPaths = [config.sops.secrets."harmonia-signing-key".path];
    settings.priority = 35;
  };

  networking.firewall.allowedTCPPorts = [5000];

  # sign all locally built paths via the nix daemon
  nix.settings.secret-key-files = [config.sops.secrets."harmonia-signing-key".path];

  # allow remote builds over SSH without root access
  nix.sshServe = {
    enable = true;
    protocol = "ssh-ng";
    write = true;
    trusted = true;
    keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJKrCyFNBmNG8etEU4JGCtaiy/6ibzr0YMgA0lwi6Fg/ nix-builder"
    ];
  };
}
