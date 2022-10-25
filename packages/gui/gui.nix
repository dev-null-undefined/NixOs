{ pkgs, ... }:

{

  imports = [
    ./discord.nix
    ./games.nix
    ./jetbrains.nix
    ./teamviewer.nix
    ./vscode.nix
    ./mathematica.nix
    ./virt-manager.nix
    ./piper.nix
  ];
  nixpkgs.config.permittedInsecurePackages = [ "electron-12.2.3" ];
  programs.kdeconnect.enable = true;
  services.gnome.sushi.enable = true;
  environment.systemPackages = with pkgs; [
    # ======= GUI programms ======
    kiterunner
    etcher
    thunderbird

    audacity

    tesseract
    gnome.gnome-screenshot

    ((emacsPackagesFor emacs).emacsWithPackages (epkgs: [ epkgs.vterm ]))
    xournalpp
    rnote
    gnome.ghex

    gnuplot
    remake
    libjpeg_original
    libjpeg_original.dev
    ncurses
    ncurses.dev
    libpng12
    libpng12.dev
    zlib
    zlib.dev
    libusb1
    libusb1.dev

    dropbox

    droidcam
    v4l-utils

    element-desktop
    gomuks

    git-open

    # Nix formatter
    nixfmt

    krita
    obs-studio
    ardour
    easyeffects
    spotify
    libreoffice
    firefox
    brave
    chromium
    copyq
    lxappearance
    wireshark
    gimp-with-plugins
    vlc
    mpv
    blender
    stable.shotcut
    font-manager
    ark
    networkmanagerapplet
    stable.gnome.nautilus
    pcmanfm
    gitg
    gparted
    stable.flameshot
    pavucontrol
    arandr
    insomnia
    alacritty
    stable.kitty
    stable.gnome.gnome-terminal
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
