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

    ../development/ides/jetbrains.nix
    ../development/ides/vscode.nix
    ../development/ides/emacs.nix
  ];

  services.gnome.sushi.enable = true;

  environment.systemPackages = with pkgs; [
    # Logitech headphones controll
    headsetcontrol

    # ======= GUI programms ======
    kiterunner
    thunderbird

    burpsuite # proxy
    gtkwave
    verilog

    # advanced hex editor
    imhex 

    ghidra
    netdiscover

    audacity

    tesseract

    gnome.gnome-screenshot
    gnome-usage
    gnome.gnome-nettool
    gnome.ghex
    gnome.nautilus-python
    gnome.gnome-terminal

    xournalpp
    rnote

    gnuplot

    dropbox

    droidcam
    v4l-utils

    tdesktop
    element-desktop
    gomuks

    git-open

    krita
    obs-studio
    ardour
    easyeffects
    spotify
    libreoffice
    onlyoffice-bin

    # Browsers
    firefox
    vivaldi
    vivaldi-ffmpeg-codecs # Additional support for proprietary codecs for Vivaldi
    brave
    chromium
    google-chrome-dev

    copyq
    lxappearance
    wireshark
    gimp-with-plugins
    feh
    vlc
    mpv
    blender
    stable.shotcut
    font-manager
    ark
    networkmanagerapplet
    pcmanfm
    gitg

    partition-manager
    stable.flameshot
    pavucontrol
    arandr
    insomnia
    alacritty
    kitty
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
