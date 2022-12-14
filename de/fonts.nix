{ pkgs, ... }: {
  fonts = {
    fonts = with pkgs; [
      ubuntu_font_family
      
      noto-fonts
      noto-fonts-cjk

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
    
    enableDefaultFonts = true;
    fontconfig = {
      defaultFonts = {
        emoji = [ "Noto Color Emoji" "Twitter Color Emoji" ];
      };
    };
  };
}
