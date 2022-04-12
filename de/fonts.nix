{ pkgs, ... }: {
  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    master.fira-code
    master.fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    font-awesome_4
    font-awesome
    meslo-lgs-nf
    jetbrains-mono
    overpass
  ];
}
