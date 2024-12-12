{
  pkgs,
  config,
  ...
}: {
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 16;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;

    font = {
      name = "Inter";
      package = pkgs.google-fonts.override {fonts = ["Inter"];};
      size = 9;
    };

    gtk3 = {extraConfig.gtk-application-prefer-dark-theme = true;};

    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders.override {
        flavor = "mocha";
        accent = "blue";
      };
    };

    theme = {
      name = "Graphite-Dark";
      package = pkgs.graphite-gtk-theme.override {
        colorVariants = ["dark"];
        # sizeVariants = [ "compact" ];
        tweaks = ["normal" "rimless" "darker"];
      };
    };
  };
}
