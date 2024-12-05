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
         '{"@timestamp":"$time_iso8601",'
           '"host":"$hostname",'
           '"server_ip":"$server_addr",'
           '"client_ip":"$remote_addr",'
           '"xff":"$http_x_forwarded_for",'
           '"domain":"$host",'
           '"url":"$uri",'
           '"referer":"$http_referer",'
           '"args":"$args",'
           '"upstreamtime":"$upstream_response_time",'
           '"responsetime":"$request_time",'
           '"request_method":"$request_method",'
           '"status":"$status",'
           '"size":"$body_bytes_sent",'
           '"request_body":"$request_body",'
           '"request_length":"$request_length",'
           '"protocol":"$server_protocol",'
           '"upstreamhost":"$upstream_addr",'
           '"file_dir":"$request_filename",'
           '"http_user_agent":"$http_user_agent"'
         '}';
    '';
  };
}
