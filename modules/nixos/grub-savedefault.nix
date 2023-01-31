{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options.boot.loader.grub.saveDefault = mkOption {
    type = types.bool;
    default = false;
    description = ''
      Whether to save the default boot entry in the grub configuration.
      This is useful if you want to boot into a different entry than the
      default one.
    '';
  };
  config = mkIf config.boot.loader.grub.saveDefault {
    boot.loader.grub.default = "saved";
  };
}
