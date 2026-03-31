{pkgs, ...}: {
  home.packages = with pkgs; [
    # Archives
    unzip
    zip

    # JSON
    jq
    fx

    # Search
    ripgrep

    # Commands
    bc
    delta
    tmux
    tealdeer
    tree
    wget
    curl
    openssh
    openssl
    htop

    # TUI tools
    dust
    duf
    ncdu
    procs
    bottom
    hyperfine

    # Multimedia
    ffmpeg
    imagemagick

    # Secrets
    age
    sops
  ];
}
