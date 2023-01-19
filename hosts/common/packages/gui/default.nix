{pkgs, ...}: {
  imports = [
    ./discord.nix
    ./games.nix
    ./teamviewer.nix
    ./mathematica.nix
    ./virt-manager.nix
    ./piper.nix
    ./via-qmk.nix
    ./gparted.nix
    ./file-managers.nix
    ./media.nix
    ./browsers.nix
    ./terminals.nix
    ./networking.nix

    ../development/ides/jetbrains.nix
    ../development/ides/vscode.nix
    ../development/ides/emacs.nix
  ];

  services.gnome.sushi.enable = true;

  environment.systemPackages = with pkgs; [
    headsetcontrol # Logitech headphones controll

    thunderbird

    gtkwave

    tesseract # OCR engine

    gnome.gnome-screenshot
    stable.flameshot

    gnome-usage
    gnome.gnome-terminal
    gnome.gnome-power-manager

    gnuplot

    tdesktop # Telegram desctop client
    element-desktop # Matrix desctop client
    gomuks # Matrix terminal client

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
