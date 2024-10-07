{
  pkgs,
  lib,
  ...
}: {
  generated.packages.development.ides = {
    jetbrains.enable = lib.mkDefault true;
    vscode.enable = lib.mkDefault true;
    emacs.enable = lib.mkDefault true;
  };

  services.gnome.sushi.enable = true;

  environment.systemPackages = with pkgs; [
    nextcloud-client

    headsetcontrol # Logitech headphones controll

    thunderbird

    # etcher # ISO etcher

    # teams unmaintained

    anki # anky

    gtkwave

    tesseract # OCR engine

    gnome-screenshot
    flameshot

    gnome-usage
    gnome-terminal
    gnome-power-manager

    gnuplot

    tdesktop # Telegram desctop client
    # element-desktop # Matrix desctop client
    # gomuks # Matrix terminal client

    libreoffice
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
