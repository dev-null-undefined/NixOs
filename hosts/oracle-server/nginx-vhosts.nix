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
    "${config.domain}" = {root = visualSorting;};
    "cpp.${config.domain}" = {
      root = "${pkgs.cppreference-doc.outPath}/share/cppreference/doc/html";
      locations."= /".extraConfig = ''
        return 301 /en;
      '';
    };
    "nixos.${config.domain}" = {
      root = "${config.system.build.manual.manualHTML}/share/doc/nixos";
    };
    "mc.${config.domain}" = {
      locations."/" = {
        proxyPass = "http://homie:8100";
        proxyWebsockets = true;
      };
    };
    "ntk.${config.domain}" = {
      locations."/" = {
        proxyPass = "http://130.61.232.56:8502";
        proxyWebsockets = true;
      };
    };

    "cloud.${config.domain}" = {
      locations."/" = {
        proxyPass = "https://homie.rat-python.ts.net";
        proxyWebsockets = true;
      };
    };
    "grafana.${config.domain}" = {
      locations."/" = {
        proxyPass = "http://homie";
        proxyWebsockets = true;
      };
    };
    "unifi.${config.domain}" = {
      locations."/" = {
        proxyPass = "https://homie:8443";
        extraConfig = ''
          proxy_ssl_verify off;
        '';
        proxyWebsockets = true;
      };
    };
    "brnikov.${config.domain}" = {
      locations."/" = {
        proxyPass = "http://brnikov:8123";
        proxyWebsockets = true;
      };
    };
    "prosek.${config.domain}" = {
      locations."/" = {
        proxyPass = "http://prosek-wagner:8123";
        proxyWebsockets = true;
      };
    };
    "home.${config.domain}" = {
      locations."/" = {
        proxyPass = "http://homie:8123";
        proxyWebsockets = true;
      };
    };
    "ny.${config.domain}" = {
      extraConfig = ''
        rewrite ^/(.*)$ http://dev-null-undefined.github.io/time-zone/$1 permanent;
      '';
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
  mergeAttrs = a: b: let
    type = builtins.typeOf a;
  in
    if type != builtins.typeOf b
    then throw "Types do not match!"
    else
      (
        if type == "string"
        then a + b
        else
          (
            if type == "bool"
            then a
            else throw "I can not merge this type ${type}."
          )
      );

  addDefaults = _: options: let
    defaultAttrs = builtins.attrNames defaultOptions;
    defaultMerged = lib.attrsets.mapAttrs (name: value:
      if builtins.elem name defaultAttrs
      then (mergeAttrs value defaultOptions.${name})
      else value)
    options;
  in
    (builtins.removeAttrs options defaultAttrs)
    // (defaultOptions // defaultMerged);
in {services.nginx.virtualHosts = lib.attrsets.mapAttrs addDefaults hosts;}
