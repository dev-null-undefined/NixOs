{self, ...}: {
  # DataPacket AI baseURL secret for opencode. The home-manager config
  # (cli/opencode.nix) resolves it via {file:/run/secrets/opencode-dp-baseurl}
  # at load time; decrypted only on the personal hosts that enable this module.
  sops.secrets."opencode-dp-baseurl" = {
    sopsFile = self.outPath + "/secrets/opencode-dp-baseurl";
    format = "binary";
    owner = "martin";
  };
}
