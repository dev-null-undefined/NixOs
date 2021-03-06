{ pkgs, config, ... }:

{
  programs.gnupg.agent.enable = true;

  imports = [ ./ranger.nix ];

  environment.systemPackages = with pkgs; [
    # dev-null.gns3-gui master.ubridge master.dynamips dev-null.gns3-server
    # Wire guard VPN
    wireguard-tools

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
    glibc
    patchelf
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
    fd
    config.boot.kernelPackages.perf
    perf-tools
    bintools-unwrapped # gcc-unwrapped
    gdb

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

    python38Full

    (python3.withPackages (e: [
        e.matplotlib
        e.pygments
    ]))

    cargo
    rustc
  ];

  # man pages
  documentation.enable = true;
  documentation.man.enable = true;
  documentation.dev.enable = true;

}
