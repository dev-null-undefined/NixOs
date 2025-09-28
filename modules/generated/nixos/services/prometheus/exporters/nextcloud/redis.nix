{config, ...}: {
  services.prometheus.exporters.redis = {
    enable = true;
    user = "nextcloud";
    extraFlags = ["-redis.addr=unix://${config.services.redis.servers.nextcloud.unixSocket}"];
  };
}
