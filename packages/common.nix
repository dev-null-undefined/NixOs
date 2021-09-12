{ pkgs, ...}:

{
  programs.gnupg.agent.enable = true;
  
  environment.systemPackages = with pkgs; [
    # TUIS
    vim_configurable neovim
    htop 
    mc ranger

    # Commands
    neofetch cpufetch
    tmux openssh gnumake tldr nmap tree gcc
    killall thefuck nix-diff nix-index

    # man page
    man man-pages

    # Utilities
    wget curl git cmake gnupg lsof whois dnsutils file

    # Languages
    python2 jdk jdk8 php nodejs nodePackages.npm
    python37Full python37Packages.virtualenv python37Packages.pip python37Packages.setuptools
    python39Full python39Packages.virtualenv python39Packages.pip python39Packages.setuptools
    # --------------------------
  ];
   
  # man pages
  documentation.enable = true;
  documentation.man.enable = true;
  documentation.dev.enable = true;
 
}
