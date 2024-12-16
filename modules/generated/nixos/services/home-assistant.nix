{
  virtualisation.oci-containers = {
    containers.homeassistant = {
      volumes = [
        "/home-assistant:/config"
        "/run/dbus:/run/dbus:ro"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment.TZ = "Europe/Prague";
      image = "ghcr.io/home-assistant/home-assistant:stable";
      extraOptions = ["--network=host" "--privileged"];
    };
  };
}
