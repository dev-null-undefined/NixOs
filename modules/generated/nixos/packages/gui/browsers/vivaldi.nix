{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    vivaldi
    vivaldi-ffmpeg-codecs # Additional support for proprietary codecs for Vivaldi
  ];
}
