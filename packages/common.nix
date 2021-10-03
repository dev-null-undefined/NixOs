{ pkgs, ...}:

{
  programs.gnupg.agent.enable = true;

  imports = [
    ./ranger.nix
  ];

  environment.systemPackages = with pkgs; [
    # Wire guard VPN
    wireguard

    # TUIS
    vim_configurable neovim
    htop 
    mc 
    sl # :D

    # Commands
    lsd
    neofetch cpufetch
    tmux openssh gnumake tldr nmap tree gcc
    killall thefuck nix-diff nix-index traceroute pciutils
    openssl most sshfs ffmpeg unzip zip 
    imagemagick
    nix-direnv
    direnv
    jq

    # Utilities
    coreutils

    # man page
    man man-pages

    # Utilities
    wget curl git cmake gnupg lsof whois dnsutils file

    # Languages
    jdk jdk8 jdk16_headless php nodejs nodePackages.npm yarn
    python27Full
    python37Full python37Packages.virtualenv python37Packages.pip python37Packages.setuptools
    python39Full python39Packages.virtualenv python39Packages.pip python39Packages.setuptools
    # --------------------------
  ];
   
  # man pages
  documentation.enable = true;
  documentation.man.enable = true;
  documentation.dev.enable = true;
 
}
