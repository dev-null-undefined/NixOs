{
  pkgs,
  config,
  lib,
  ...
}: let
  ports = with config.services.nginx; [
    defaultSSLListenPort
    defaultHTTPListenPort
  ];
in {
  generated.services.nginx.catch_all.enable = lib.mkDefault true;

  generated.services.nginx.elastic.enable =
    lib.mkDefault config.generated.services.elastic.enable;

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

    statusPage = lib.mkDefault true;
    virtualHosts.localhost.extraConfig = ''
      access_log  /var/log/nginx/access.log  main;
    '';

    commonHttpConfig = ''
      real_ip_header X-Real-IP;
      log_format main escape=json
              '{"time_local":"$time_local",'
               '"remote_user":"$remote_user",'
               '"http_user_agent":"$http_user_agent",'
               '"http_referer":"$http_referer",'
               '"remote_addr":"$remote_addr",'
               '"request_length":$request_length,'
               '"request_time":$request_time,'
               '"body_bytes_sent":$body_bytes_sent,'
               '"request":"$request",'
               '"status":$status,'
               '"server_name":"$server_name"'
              '}';
    '';
  };
}
