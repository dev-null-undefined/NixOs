let
  ports = {
    allowedTCPPorts = [
      8080 # Port for UAP to inform controller.
      8443 # UAP inform controller https
      8880 # Port for HTTP portal redirect, if guest portal is enabled.
      8843 # Port for HTTPS portal redirect, ditto.
      6789 # Port for UniFi mobile speed test.
    ];
    allowedUDPPorts = [
      3478 # UDP port used for STUN.
      10001 # UDP port used for device discovery.
      1900 # Required for Make controller discoverable on L2 network option
    ];
  };
in {
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      unifi = {
        image = "lscr.io/linuxserver/unifi-controller:latest";
        ports =
          (builtins.map
            (port: let str = builtins.toString port; in "${str}:${str}/udp")
            ports.allowedUDPPorts)
          ++ (builtins.map
            (port: let str = builtins.toString port; in "${str}:${str}")
            ports.allowedTCPPorts);
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Etc/UTC";
          MEM_LIMIT = "1024";
          MEM_STARTUP = "1024";
        };
        volumes = ["/unifi:/config"];
      };
    };
  };
  networking.firewall = {inherit (ports) allowedTCPPorts allowedUDPPorts;};
}
