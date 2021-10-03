{ pkgs, ... }:

let
    stable = import <nixos-stable> { config = { allowUnfree = true; }; };
in {
    imports =
      [
        ./common.nix
        ./zsh.nix
        ./gui/gui.nix
        # ./audio.nix
      ];
     
    environment.systemPackages = with pkgs; [
      papirus-icon-theme
      # ----- Terminal tools -----
      # TUI
      lynx
      bpytop glances gotop nload iftop nethogs
      mutt
      nyancat pipes cmatrix
      hyperfine

      # Commands
      home-manager screenfetch gnumake
      feh youtube-dl asciinema

      # Utilities
      pandoc light blueman fzf autorandr cron bat lolcat
      libnotify libinput-gestures hunspell aspell gspell xclip
      # --------------------------

      # ======= GUI programms ======
      spotify
      libreoffice
      firefox brave chromium
      copyq lxappearance wireshark
      gimp-with-plugins vlc blender stable.shotcut
      font-manager ark 
      dolphin gnome.nautilus pcmanfm 
      gparted flameshot pavucontrol arandr
      insomnia alacritty kitty stable.mysql-workbench

      # Spell checking
      hunspell
      hunspellDicts.en-us hunspellDicts.cs-cz

      # Libs
      xorg.libX11 xorg.libXinerama xorg.libXft imlib2

      # dev tools
      valgrind glibc

      # FIT - TZP
      mathematica

      hidapi
  ];
  nixpkgs.config = {
      allowUnfree = true;
      #allowBroken = true;
  };

}
