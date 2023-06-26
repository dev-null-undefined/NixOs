{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    gnome.adwaita-icon-theme
  ];
  fonts = {
    fonts = with pkgs; [
      material-symbols

      ubuntu_font_family

      noto-fonts
      noto-fonts-cjk

      twemoji-color-font
      twitter-color-emoji
      noto-fonts-emoji

      liberation_ttf

      fira-code
      fira-code-symbols

      dejavu_fonts
      carlito
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
      font-awesome_4
      font-awesome

      meslo-lgs-nf
      jetbrains-mono

      overpass
      monocraft
    ];

    fontDir.enable = true;

    enableDefaultFonts = false;

    fontconfig = {
      defaultFonts = {
        #serif = ["Noto Serif" "Noto Color Emoji"];
        #sansSerif = ["Noto Sans" "Noto Color Emoji"];
        emoji = ["Noto Color Emoji" "Twitter Color Emoji"];
        #monospace = ["MesloLGS NF" "Noto Color Emoji"];
      };
    };
  };
}
