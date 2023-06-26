{
  pkgs,
  lib,
  ...
}: {
  generated.home.cli.nvim.enable = lib.mkDefault true;
}
