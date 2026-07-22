{config, ...}: let
  stateDir = "/var/lib/cleanuparr";
  uid = 900;
  port = 11011;
in {
  # Cleanuparr: watches the Sonarr/Radarr queues, removes+blocklists malware/stalled/failed
  # downloads and triggers a re-search. Replaces a hand-rolled cleanup script — community-
  # maintained malware patterns. Configured via its web UI (http://homie:${toString port}),
  # state persisted in ${stateDir}. Not in nixpkgs, so run as a pinned OCI container.
  virtualisation = {
    podman.enable = true;
    oci-containers.backend = "podman";
    oci-containers.containers.cleanuparr = {
      image = "ghcr.io/cleanuparr/cleanuparr:2.9.16";
      # Host networking so it can reach Sonarr/Radarr on 127.0.0.1 and qBittorrent inside the
      # protonvpn netns (10.200.200.2:9091); the web UI binds host 0.0.0.0:${toString port}
      # (firewalled on WAN, reachable over Tailscale).
      extraOptions = ["--network=host"];
      volumes = ["${stateDir}:/config"];
      environment = {
        PORT = toString port;
        TZ = config.time.timeZone;
        PUID = toString uid;
        PGID = toString uid;
      };
    };
  };

  users.users.cleanuparr = {
    isSystemUser = true;
    group = "cleanuparr";
    uid = uid;
  };
  users.groups.cleanuparr.gid = uid;

  systemd.tmpfiles.rules = [
    "d ${stateDir} 0750 cleanuparr cleanuparr -"
  ];
}
