{lib, ...}: {
  generated.home = {
    cli.enable = lib.mkDefault true;
    shells.enable = lib.mkDefault true;
  };
}
