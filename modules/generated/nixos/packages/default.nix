{
  pkgs,
  config,
  lib,
  ...
}: {
  generated.packages = {
    btrfs-tools.enable = lib.mkDefault true;
    tui.enable = lib.mkDefault true;
    zsh.enable = lib.mkDefault true;
    development.enable = lib.mkDefault true;
  };

  environment.systemPackages = with pkgs; [
    # Utilities
    coreutils
    netcat-gnu
    stress
    # pee sponge vipe etc..
    moreutils

    # man page
    man
    man-pages
    man-pages-posix
    linux-manual

    # Archives
    unzip
    zip
    lrzip
    unrar-wrapper

    direnv
    ripgrep
    jq # json
    bc # calculator
    mat2 # meta data stripper
    onionshare

    usbutils
    dhcp

    # Commands
    delta # diff
    tmux # term multiplexor
    tealdeer
    navi # interactive tldr
    tree
    most
    sshfs
    openssh
    openssl
    killall
    thefuck
    pciutils

    # multimedia manipulation
    ffmpeg
    imagemagick

    # Utilities
    wget
    curl

    pkg-config
    dbus
  ];
}
