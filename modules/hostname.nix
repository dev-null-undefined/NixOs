{ lib, config, ... }: {
  # Copy from x10an14#3764
  options.hostname = lib.mkOption {
    type = lib.types.str;
    description = "Hostname of the current system";
  };
  config = { networking.hostName = config.hostname; };
}
