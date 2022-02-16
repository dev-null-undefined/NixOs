{ pkgs, ... }:

{
  programs.gnupg.agent.enable = true;

  imports = [ ./ranger.nix ];

  environment.systemPackages = with pkgs; [
    # Nixos
    hydra-unstable
    # Wire guard VPN
    wireguard

    # TUIS
    vim_configurable
    neovim
    htop
    mc
    sl # :D

    # Commands
    lsd
    # pipe monitor
    pv
    tmux
    tldr
    tree
    most
    sshfs
    openssh
    openssl
    gnumake
    nmap
    traceroute
    gcc
    killall
    thefuck
    nix-diff
    nix-index
    pciutils
    unzip
    zip
    nix-direnv
    direnv
    ripgrep
    jq
    bc
    mat2
    onionshare

    # Utilities
    coreutils

    # man page
    man
    man-pages

    # multimedia manipulation
    ffmpeg
    imagemagick

    # Utilities
    wget
    curl
    git
    cmake
    gnupg
    lsof
    whois
    dnsutils
    file
    linuxKernel.packages.linux_5_10.perf
    bintools-unwrapped # gcc-unwrapped

    # Java
    jdk
    jdk8
    jdk11

    # Languages
    php
    nodejs
    nodePackages.npm
    yarn

    # Python
    python27Full

    python37Full
    python37Packages.virtualenv
    python37Packages.pip
    python37Packages.setuptools

    python39Full
    python39Packages.virtualenv
    python39Packages.pip
    python39Packages.setuptools
  ];

  # man pages
  documentation.enable = true;
  documentation.man.enable = true;
  documentation.dev.enable = true;

}
