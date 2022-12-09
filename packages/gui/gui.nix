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

    burpsuite # proxy
    gtkwave
    verilog

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

    ((emacsPackagesFor emacs).emacsWithPackages (epkgs: [ epkgs.vterm ]))
    xournalpp
    rnote

    gnuplot
    remake

    dropbox

    droidcam
    v4l-utils

    tdesktop
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
    pcmanfm
    gitg
 
    gparted
    # gparted dependecies
    exfatprogs
    btrfs-progs
    dosfstools
    f2fs-tools
    gpart
    mtools 
    ntfs3g
    e2fsprogs
    lvm2
    cryptsetup

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
