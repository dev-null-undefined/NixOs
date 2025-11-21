{
  self,
  lib,
  config,
  ...
}: let
in {
  options = let
    inherit (config) domain;

    host-options = {
      name,
      config,
      ...
    }: {
      options = {
        base-domain = lib.mkOption {
          type = lib.types.str;
          default = domain;
          description = "Base domain for the HTTP service.";
        };
        ssl = lib.mkOption {
          type = lib.types.enum ["acme" "custom" "none"];
          default = "custom";
          description = "Enable SSL for the host.";
        };
        services =
          builtins.mapAttrs (
            service: service-cfg: {
              enable = lib.mkOption {
                type = lib.types.bool;
                default = service-cfg.public;
                description = "Whether the service should be exposed.";
              };
              ssl = lib.mkOption {
                type = lib.types.enum ["acme" "custom" "none"];
                default = config.ssl;
                description = "SSL configuration for the service.";
              };
            }
          )
          self.nixosConfigurations.${name}.config.services.http-services;
      };
    };
  in {
    hosts = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule host-options);
      default = {};
      description = "Configuration for hosts to be exposed.";
    };
  };

  services.nginx.virtualHosts =
    lib.foldlAttrs (
      res: host-name: host:
        res
        // (
          lib.foldlAttrs (
            acc: service-name: service: let
              service-config = self.nixosConfigurations.${host-name}.config.services.http-services.${service-name};
              service-domain = "${service-config.prefix}.${host.base-domain}";
            in
              acc
              // (lib.attrsets.optionalAttrs service.enable)
              {
                "${service-domain}" =
                  {
                    locations."/" = {
                      proxyPass = service-config.url;
                      proxyWebsockets = true;
                    };

                    http3 = true;
                    quic = true;
                    extraConfig = ''
                      access_log  /var/log/nginx/access.log  main;
                    '';
                  }
                  // (
                    if service.ssl == "custom"
                    then {
                      forceSSL = true;
                      addSSL = true;
                      sslCertificate = "/etc/ssl/certs/${service-domain}.crt";
                      sslCertificateKey = "/etc/ssl/private/${service-domain}.key";
                    }
                    else if service.ssl == "acme"
                    then {
                      enableACME = true;
                      forceSSL = true;
                    }
                    else if service.ssl == "none"
                    then {
                    }
                    else abort "Invalid SSL option: ${service.ssl}"
                  );
              }
          ) {}
          host.services
        )
    ) {}
    config.generated.services.nginx.expose.hosts;
}
