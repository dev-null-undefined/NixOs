{config, ...}: {
  virtualisation = {
    podman.enable = true;
    oci-containers.backend = "podman";
  };

  services.unifi-os-server = {
    enable = true;
    uosSystemIP = "192.168.1.1";
    # The module publishes container ports to 0.0.0.0 and reaches them via DNAT,
    # so its own firewall opening is global (all interfaces incl. WAN) and
    # misleading. Turn it off and gate access explicitly in hosts/homie/router.nix
    # (LAN-only INPUT for adoption ports + WAN prerouting drop). UI (11443) is
    # reached over localhost by nginx + the unpoller exporter.
    openFirewallUiPort = false;
    openFirewallServicePorts = false;
    # Only publish what the LAN needs: device inform (8080), STUN (3478),
    # discovery (10001), web UI (11443). Drop the ports nothing here uses so they
    # aren't published or DNAT'd at all.
    ports = {
      controllerHttps = null; # 8443 — UI/API served via ui (11443), not this
      mobileSpeedTest = null; # 6789 — unused
      httpCaptivePortal = null; # 8880 — no guest portal
      httpsCaptivePortal = null; # 8843 — no guest portal
    };
    # RabbitMQ inside the container hits the default 2048 pid limit and dies on Erlang VM startup.
    extraOptions = ["--pids-limit=8192"];
    environment = {
      TZ = config.time.timeZone;
    };
  };
}
