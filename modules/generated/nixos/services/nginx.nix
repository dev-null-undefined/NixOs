{
  pkgs,
  config,
  ...
}: let
  ports = with config.services.nginx; [
    defaultSSLListenPort
    defaultHTTPListenPort
  ];
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

    commonHttpConfig = ''
      real_ip_header X-Real-IP;
      log_format main '$remote_addr $host $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$request_body"';
    '';
  };
}
