{lib, ...}: {
  generated.home.desktop.common = {
    gtk.enable = lib.mkDefault true;
    dconf.enable = lib.mkDefault true;
    qt.enable = lib.mkDefault true;
  };
}
