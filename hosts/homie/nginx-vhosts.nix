{
  pkgs,
  config,
  lib,
  ...
}: let
  defaultOptions = {
    enableACME = true;
    forceSSL = true;
    http3 = true;
    extraConfig = ''
      access_log  /var/log/nginx/access.log  main;
    '';
  };
in {services.nginx.virtualHosts = lib.attrsets.mapAttrs addDefaults hosts;}
