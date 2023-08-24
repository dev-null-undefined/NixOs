{lib, ...}: {
  generated.home = {
    cli.enable = lib.mkDefault true;
    shells.zsh.enable = lib.mkDefault true;
  };
}
