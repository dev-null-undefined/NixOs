{ pkgs, config, ... }:

{
    imports =
      [
        ./common.nix
        ./zsh.nix
      ];

    environment.systemPackages = with pkgs; [
      # ----- Terminal tools -----
      # TUI
      lynx
      android-tools
      bpytop glances gotop nload iftop nethogs bottom
      mutt
      nyancat pipes cmatrix
      hyperfine
      mycli
      screenfetch neofetch cpufetch macchina

      # Commands
      lsd home-manager screenfetch gnumake
      feh youtube-dl asciinema

      # Utilities
      pandoc fzf cron bat lolcat
      # --------------------------

  ];
  nixpkgs.config = {
      allowUnfree = true;
      #allowBroken = true;
  };

}
