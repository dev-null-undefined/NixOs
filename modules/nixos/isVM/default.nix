{lib, ...}: {
  options.isVM = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Whether the current system is VM";
  };
}
