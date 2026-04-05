{
  pkgs,
  config,
  lib,
  ...
}: let
  r = config.registry;
  svc = r.services;

  # http://<host>:<port> for a registry service
  proxyTo = name: "http://${svc.${name}.host}:${toString svc.${name}.port}";

  # <subdomain>.<domain> for a registry service
  vhost = name: "${svc.${name}.subdomain}.${r.domain}";

  visualSorting = pkgs.fetchFromGitHub {
    owner = "dev-null-undefined";
    repo = "VisualSorting";
    rev = "2b36d720ea0bb944ddb8352cc1c1b125a399bcc0";
    sha256 = "sha256-H/qSpJglOE1DhVfxSbM0Sac774erNhSoxCr7QRnvU0U=";
  };
  hosts =
    {
      "${r.domain}" = {
        root = visualSorting;
      };
      "cpp.${r.domain}" = {
        root = "${pkgs.cppreference-doc.outPath}/share/cppreference/doc/html";
        locations."= /".extraConfig = ''
          return 301 /en;
        '';
      };
      "nixos.${r.domain}" = {
        root = "${config.system.build.manual.manualHTML}/share/doc/nixos";
      };
      "${vhost "crafty"}" = {
        locations."/" = {
          proxyPass = proxyTo "crafty";
          proxyWebsockets = true;
        };
      };
      "${vhost "nextcloud"}" = {
        locations."/" = {
          proxyPass = "https://${svc.nextcloud.host}.${r.tailnetDomain}";
          proxyWebsockets = true;
        };
        extraConfig = ''
          client_max_body_size 32G;
        '';
      };
      "${vhost "grafana"}" = {
        locations."/" = {
          proxyPass = "http://${svc.grafana.host}";
          proxyWebsockets = true;
        };
      };
      "${vhost "unifi"}" = {
        locations."/" = {
          proxyPass = "https://${svc.unifi.host}:${toString svc.unifi.port}";
          extraConfig = ''
            proxy_ssl_verify off;
          '';
          proxyWebsockets = true;
        };
      };
      "${vhost "home-assistant-brnikov"}" = {
        locations."/" = {
          proxyPass = proxyTo "home-assistant-brnikov";
          proxyWebsockets = true;
        };
      };
      "${vhost "home-assistant-prosek"}" = {
        locations."/" = {
          proxyPass = proxyTo "home-assistant-prosek";
          proxyWebsockets = true;
        };
      };
      "${vhost "home-assistant"}" = {
        locations."/" = {
          proxyPass = proxyTo "home-assistant";
          proxyWebsockets = true;
        };
      };
      "ny.${r.domain}" = {
        extraConfig = ''
          rewrite ^/(.*)$ http://dev-null-undefined.github.io/time-zone/$1 permanent;
        '';
      };
      # Arr stack
      "${vhost "jellyfin"}" = {
        locations."/" = {
          proxyWebsockets = true;
          proxyPass = proxyTo "jellyfin";
        };
      };
      "${vhost "jellyseerr"}" = {
        locations."/" = {
          proxyWebsockets = true;
          proxyPass = proxyTo "jellyseerr";
        };
      };
      "${vhost "prowlarr"}" = {
        locations."/" = {
          proxyWebsockets = true;
          proxyPass = proxyTo "prowlarr";
        };
      };
      "${vhost "sonarr"}" = {
        locations."/" = {
          proxyWebsockets = true;
          proxyPass = proxyTo "sonarr";
        };
      };
      "${vhost "radarr"}" = {
        locations."/" = {
          proxyWebsockets = true;
          proxyPass = proxyTo "radarr";
        };
      };
      "${vhost "transmission"}" = {
        locations."/" = {
          proxyWebsockets = true;
          proxyPass = proxyTo "transmission";
        };
      };
    }
    // (lib.attrsets.optionalAttrs config.generated.services.atuin.enable {
      "${vhost "atuin"}" = {
        locations."/" = {
          proxyWebsockets = true;
          proxyPass = "http://localhost:${toString svc.atuin.port}";
        };
      };
    });
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
    defaultMerged =
      lib.attrsets.mapAttrs (
        name: value:
          if builtins.elem name defaultAttrs
          then (mergeAttrs value defaultOptions.${name})
          else value
      )
      options;
  in
    (builtins.removeAttrs options defaultAttrs) // (defaultOptions // defaultMerged);
in {
  services.nginx.virtualHosts = lib.attrsets.mapAttrs addDefaults hosts;
}
