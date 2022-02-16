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
    ((emacsPackagesNgGen emacs).emacsWithPackages (epkgs: [ epkgs.vterm ]))
    xournalpp
    gnome.ghex

    dropbox

    droidcam
    v4l-utils

    element-desktop
    gomuks

    master.krita
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
    stable.kitty # stable.mysql-workbench

    # Spell checking
    hunspell
    hunspellDicts.en-us
    hunspellDicts.cs-cz

  ];
}
