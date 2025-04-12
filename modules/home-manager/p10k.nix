{lib, ...}:
with lib; {
  options.p10k.colors = mkOption {
    type = types.attrsOf types.number;
    default = {};
    description = "Custom colors for p10k.";
  };
}
