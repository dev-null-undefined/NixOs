{
  lib,
  config,
  ...
}: let
  cfg = config;
  http-service-options = {
    name,
    config,
    ...
  }: {
    options = {
      hostname = lib.mkOption {
        type = lib.types.str;
        default = cfg.hostname; # using tailscale to connect
        description = "Hostname for the HTTP service.";
      };
      port = lib.mkOption {
        type = lib.types.int;
        default = cfg.services."${name}".port;
        description = "Port on which the HTTP service listens.";
      };
      ssl = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable SSL for the HTTP service.";
      };
      prefix = lib.mkOption {
        type = lib.types.str;
        default = name;
        description = "Domain prefix to use when exposing the service.";
      };
      url = lib.mkOption {
        type = lib.types.str;
        default = "${
          if config.ssl
          then "https"
          else "http"
        }://${config.hostname}:${toString config.port}";
        description = "Full URL to access the HTTP service.";
      };
      public = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether the service should be exposed.";
      };
    };
  };
in {
  options.services.http-services = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule http-service-options);
    default = {};
    description = "Configuration for HTTP services.";
  };
}
