{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
  ];
  fonts = {
    packages = with pkgs; [
      material-symbols

      ubuntu-classic

      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji

      twemoji-color-font
      twitter-color-emoji

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

      nerd-fonts.meslo-lg
    ];

    fontDir.enable = true;

    fontconfig = {
      defaultFonts = {
        monospace = ["Meslo LG M Regular Nerd Font Complete Mono"];
        serif = ["Noto Serif" "Noto Color Emoji"];
        sansSerif = ["Noto Sans" "Noto Color Emoji"];
        emoji = ["Noto Color Emoji" "Twitter Color Emoji"];
      };
    };
  };
}
