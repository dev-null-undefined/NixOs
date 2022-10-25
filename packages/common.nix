{ pkgs, config, ... }:

{
  programs.firejail.enable = true;
  security.apparmor.enable = true;

  imports = [ ./ranger.nix ];

  environment.systemPackages = with pkgs; [
    dev-null.ruby
    # dev-null.gns3-gui master.ubridge master.dynamips dev-null.gns3-server
    # Wire guard VPN
    wireguard-tools

    # TUIS
    vim_configurable
    neovim
    htop
    mc
    aria
    sl # :D
    termdown # timer/stopwatch

    # Commands
    delta
    lsd
    cloc
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
    unrar-wrapper
    nix-direnv
    direnv
    ripgrep
    jq
    bc
    mat2
    onionshare

    # Utilities
    coreutils
    usbutils
    dhcp

    # man page
    man
    man-pages

    # multimedia manipulation
    ffmpeg
    imagemagick

    # Utilities
    mitmproxy # https proxy
    burpsuite
    wget
    curl
    git
    stable.cmake
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
    jprofiler
    visualvm

    # Languages
    php
    nodejs
    nodePackages.npm
    yarn

    # C# mrkda jazyk
    dotnet-sdk
    mono
    msbuild

    # Python
    python27Full

    (python3.withPackages
      (e: [ e.matplotlib e.pygments e.numpy e.tkinter e.pandas ]))

    # RUST
    cargo
    rustc
    pkg-config
    dbus

    # C++ intepreter
    cling

    # Clang
    clang_14
    lldb_14
    libclang
    clang_multi
    clang-tools
    clang-manpages
    clang-analyzer

  ];

  # man pages
  documentation.enable = true;
  documentation.man.enable = true;
  documentation.dev.enable = true;

}
