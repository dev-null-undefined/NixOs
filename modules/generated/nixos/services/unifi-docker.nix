{
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      unifi = {
        image = "lscr.io/linuxserver/unifi-controller:latest";
        ports = [
          "8443:8443"
          "3478:3478/udp"
          "10001:10001/udp"
          "8080:8080"
          "1900:1900/udp"
          "8843:8843"
          "8880:8880"
          "6789:6789"
        ];
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
}
