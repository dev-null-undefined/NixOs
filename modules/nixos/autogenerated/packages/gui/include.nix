{
  pkgs,
  lib,
  ...
}: {
  generated.packages.development.ides.jetbrains.enable = lib.mkDefault true;
  generated.packages.development.ides.vscode.enable = lib.mkDefault true;
  generated.packages.development.ides.emacs.enable = lib.mkDefault true;

  services.gnome.sushi.enable = true;

  environment.systemPackages = with pkgs; [
    headsetcontrol # Logitech headphones controll

    thunderbird

    gtkwave

    tesseract # OCR engine

    gnome.gnome-screenshot
    flameshot

    gnome-usage
    gnome.gnome-terminal
    gnome.gnome-power-manager

    gnuplot

    tdesktop # Telegram desctop client
    element-desktop # Matrix desctop client
    gomuks # Matrix terminal client

    stable.libreoffice
    onlyoffice-bin

    copyq

    lxappearance
    font-manager

    ark # archive manager
    partition-manager

    gitg
    git-open

    arandr

    ccls
    nodePackages.bash-language-server
    nodePackages.typescript-language-server
    shellcheck

    # Spell checking
    hunspell
    hunspellDicts.en-us
    hunspellDicts.cs-cz

    proselint
  ];
}
