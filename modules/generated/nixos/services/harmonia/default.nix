{
  config,
  self,
  ...
}: let
  r = config.registry;
  publicPort = r.services.harmonia.port;
  internalPort = r.services.harmonia.internalPort;
  tailscaleIp = r.hosts.${config.networking.hostName}.tailscaleIp;
in {
  sops.secrets."harmonia-signing-key" = {
    sopsFile = self.outPath + "/secrets/harmonia-signing-key";
    format = "binary";
  };

  services.harmonia.cache = {
    enable = true;
    signKeyPaths = [config.sops.secrets."harmonia-signing-key".path];
    settings = {
      bind = "127.0.0.1:${toString internalPort}";
      priority = 35;
      workers = 16;
    };
  };

  # nginx fronts harmonia, listening only on the Tailscale IP. harmonia itself
  # is loopback-only so the public port is unreachable except via tailnet.
  services.nginx.virtualHosts."harmonia" = {
    listen = [
      {
        addr = tailscaleIp;
        port = publicPort;
        ssl = false;
      }
    ];
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString internalPort}";
      extraConfig = ''
        proxy_buffering on;
        proxy_request_buffering on;
        proxy_connect_timeout 30s;
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
        client_max_body_size 0;
      '';
    };
  };

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
