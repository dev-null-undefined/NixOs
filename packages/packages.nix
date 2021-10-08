{ pkgs, config, ... }:

{
    imports =
      [
        ./common.nix
        ./zsh.nix
        ./gui/gui.nix
        ./docker.nix
      ];
     
    environment.systemPackages = with pkgs; [
      # ----- Terminal tools -----
      # TUI
      lynx
      bpytop glances gotop nload iftop nethogs bottom
      mutt
      nyancat pipes cmatrix
      hyperfine
      mycli
      screenfetch neofetch cpufetch macchina

      # Commands
      home-manager gnumake
      feh youtube-dl asciinema

      # Utilities
      pandoc light blueman fzf autorandr cron bat lolcat
      libnotify libinput-gestures hunspell aspell gspell xclip
      # --------------------------

      # Libs
      xorg.libX11 xorg.libXinerama xorg.libXft imlib2

      # dev tools
      valgrind glibc

      hidapi
  ];
  nixpkgs.config = {
      allowUnfree = true;
      #allowBroken = true;
  };

}
