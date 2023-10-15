{
  pkgs,
  config,
  lib,
  ...
}: let
  visualSorting = pkgs.fetchFromGitHub {
    owner = "dev-null-undefined";
    repo = "VisualSorting";
    rev = "2b36d720ea0bb944ddb8352cc1c1b125a399bcc0";
    sha256 = "sha256-H/qSpJglOE1DhVfxSbM0Sac774erNhSoxCr7QRnvU0U=";
  };
  hosts = {
    "${config.domain}" = {
      root = visualSorting;
      locations."~ /\\.git".extraConfig = ''
        deny all;
      '';
    };
    "cpp.${config.domain}" = {
      root = "${pkgs.cppreference-doc.outPath}/share/cppreference/doc/html";
      locations."= /".extraConfig = ''
        return 301 /en;
      '';
    };
    "nixos.${config.domain}" = {
      root = "${config.system.build.manual.manualHTML}/share/doc/nixos";
    };
    "dynmap.${config.domain}" = {
      locations."/" = {
        proxyPass = "http://135.125.16.193:8034";
        proxyWebsockets = true;
      };
    };
    "brnikov.${config.domain}" = {
      locations."/" = {
        proxyPass = "http://10.100.0.2:8123";
        proxyWebsockets = true;
      };
    };
  };
  defaultOptions = {
    enableACME = true;
    forceSSL = true;
    http3 = true;
    extraConfig = ''
      access_log  /var/log/nginx/access.log  main;
    '';
  };
  addDefaults = _: value:
    value // defaultOptions;
in {
  services.nginx.virtualHosts = lib.attrsets.mapAttrs addDefaults hosts;
}
