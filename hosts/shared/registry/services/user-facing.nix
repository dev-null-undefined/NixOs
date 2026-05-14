{
  registry.services = {
    grafana = {
      host = "homie";
      port = 3000;
      subdomain = "grafana";
    };
    jellyfin = {
      host = "homie";
      port = 8096;
      subdomain = "jellyfin";
    };
    jellyseerr = {
      host = "homie";
      port = 5055;
      subdomain = "jellyseerr";
    };
    sonarr = {
      host = "homie";
      port = 8989;
      subdomain = "sonarr";
    };
    radarr = {
      host = "homie";
      port = 7878;
      subdomain = "radarr";
    };
    prowlarr = {
      host = "homie";
      port = 9696;
      subdomain = "prowlarr";
    };
    bazarr = {
      host = "homie";
      port = 6767;
      subdomain = "bazarr";
    };
    transmission = {
      host = "homie-vpn";
      port = 9091;
      subdomain = "transmission";
    };
    nextcloud = {
      host = "homie";
      port = 443;
      subdomain = "cloud";
    };
    unifi = {
      host = "homie";
      port = 8443;
      subdomain = "unifi";
    };
    crafty = {
      host = "homie";
      port = 8100;
      subdomain = "mc";
    };
    minecraft = {
      host = "homie";
      port = 25565;
    };
  };
}
