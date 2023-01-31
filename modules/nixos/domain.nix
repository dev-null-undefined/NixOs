{
  lib,
  config,
  ...
}: {
  options.domain = lib.mkOption {
    type = lib.types.str;
    default = config.hostname;
    description = "Public DNS domain.";
  };
}
