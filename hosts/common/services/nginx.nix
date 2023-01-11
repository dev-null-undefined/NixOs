{
  pkgs,
  config,
  ...
}: let
  visualSorting = pkgs.fetchFromGitHub {
    owner = "dev-null-undefined";
    repo = "VisualSorting";
    rev = "2fdedd6bab68384536ece120ec940fde7b8a024a";
    sha256 = "sha256-2ZeHGvGSrbyuppjzIsnkZTKi7mPXlJuLy9ksOnqeFrs=";
  };
  ports = with config.services.nginx; [defaultSSLListenPort defaultHTTPListenPort];
in {
  # Enable http and https ports
  networking.firewall.allowedTCPPorts = ports;
  networking.firewall.allowedUDPPorts = ports;

  services.nginx = {
    enable = true;

    package = pkgs.nginxQuic;

    # Use recommended settings
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."dev-null.me" = {
      enableACME = true;
      forceSSL = true;
      http3 = true;
      root = visualSorting;
      locations."~ /\\.git".extraConfig = ''
        deny all;
      '';
    };
  };
}
