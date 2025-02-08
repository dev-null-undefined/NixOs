{
  pkgs,
  lib,
  ...
}: {
  programs.yt-dlp = {
    enable = true;
    settings = {
      embed-metadata = true;
      embed-thumbnail = true;
      embed-subs = true;
      sub-langs = "en.*";
      downloader = lib.getExe pkgs.aria2;
    };
  };
}
