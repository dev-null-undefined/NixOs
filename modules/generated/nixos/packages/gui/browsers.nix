{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Browsers
    firefox
    vivaldi
    vivaldi-ffmpeg-codecs # Additional support for proprietary codecs for Vivaldi
    brave
    chromium
    google-chrome-dev
  ];
}
