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

  environment.systemPackages = with pkgs; [
    # ======= GUI programms ======
    ((emacsPackagesFor emacs).emacsWithPackages (epkgs: [ epkgs.vterm ]))
    xournalpp
    gnome.ghex

    gnuplot

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
    dolphin
    gnome.nautilus
    pcmanfm
    gitg
    gparted
    flameshot
    pavucontrol
    arandr
    insomnia
    alacritty
    stable.kitty
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
