{
  lib,
  config,
  ...
}: {
  options.domain = lib.mkOption {
    type = lib.types.str;
    description = "Public DNS domain.";
  };
}
