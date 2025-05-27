{
  config,
  pkgs,
  lib,
  ...
}: {
  # Create a shared group for many services
  users.groups."shared-media" = {};

  services = {
    audiobookshelf.group = "shared-media";
    bazarr.group = "shared-media";
    jellyfin.group = "shared-media";
    radarr.group = "shared-media";
    readarr.group = "shared-media";
    sonarr.group = "shared-media";
    immich.group = "shared-media";
    calibre-web.group = "shared-media";
  };

  generated.services.media.qbittorrent.group = "shared-media";

  services = {
    jellyfin.enable = true;

    jellyseerr.enable = true;

    prowlarr.enable = true;

    flaresolverr = {
      enable = true;
      package = pkgs.flaresolverr;
    };

    sonarr = {enable = true;};
    radarr = {enable = true;};

    bazarr = {enable = true;};

    readarr = {enable = true;};
  };
}
