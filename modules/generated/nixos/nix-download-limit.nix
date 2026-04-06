{
  lib,
  config,
  ...
}: let
  cf = config.generated.nix-download-limit;
in {
  options = {
    max-speed = lib.mkOption {
      type = lib.types.ints.positive;
      description = "Maximum total download speed in Mbit/s";
      example = 200;
    };
    http-connections = lib.mkOption {
      type = lib.types.ints.positive;
      default = 4;
      description = "Number of parallel HTTP connections for downloads";
    };
  };

  nix.settings = {
    http-connections = cf.http-connections;
    # per-connection limit in KB/s: convert Mbit/s to KB/s, divide by connections
    download-speed = cf.max-speed * 1000 / 8 / cf.http-connections;
  };
}
