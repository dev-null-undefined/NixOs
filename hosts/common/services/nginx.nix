{
  pkgs,
  config,
  ...
}: let
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

  };
}
