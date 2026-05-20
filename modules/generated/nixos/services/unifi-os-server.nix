{config, ...}: {
  virtualisation = {
    podman.enable = true;
    oci-containers.backend = "podman";
  };

  services.unifi-os-server = {
    enable = true;
    uosSystemIP = "192.168.1.1";
    openFirewallUiPort = true;
    openFirewallServicePorts = true;
    # RabbitMQ inside the container hits the default 2048 pid limit and dies on Erlang VM startup.
    extraOptions = ["--pids-limit=8192"];
    environment = {
      TZ = config.time.timeZone;
    };
  };
}
