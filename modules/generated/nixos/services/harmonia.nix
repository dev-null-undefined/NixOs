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

  # dedicated user for remote nix builds (minimal permissions)
  users.users.nix-builder = {
    isSystemUser = true;
    group = "nix-builder";
    shell = "/bin/sh";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOc1jqQ8khYrYOChEWLTkpAjVmvBdF7nStHpekLil0zu nix-builder"
    ];
  };
  users.groups.nix-builder = {};
  nix.settings.trusted-users = ["nix-builder"];
}
