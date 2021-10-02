{ pkgs, ... }:

let
    stable = import <nixos-stable> { config = { allowUnfree = true; }; };
in {
    imports =
      [
        ./common.nix
        ./zsh.nix
        ./games.nix
        ./discord.nix
        ./vscode.nix
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
      lsd home-manager screenfetch gnumake
      feh youtube-dl asciinema

      # Utilities
      pandoc light blueman fzf autorandr cron bat lolcat
      libnotify libinput-gestures hunspell aspell gspell xclip
      # --------------------------

      # Notications deamon
      dunst

      # ======= GUI programms ======
      spotify
      libreoffice
      firefox brave chromium
      copyq lxappearance wireshark
      gimp-with-plugins vlc blender stable.shotcut
      font-manager ark 
      dolphin gnome.nautilus pcmanfm 
      gparted flameshot pavucontrol arandr
      insomnia alacritty stable.mysql-workbench

      # ------- Programming -------
      # IDEs
      #    JetBrains
      jetbrains.idea-ultimate jetbrains.phpstorm jetbrains.jdk jetbrains.pycharm-professional
      
      (pkgs.jetbrains.clion.overrideAttrs (old: rec{
        version = "2021.2.2";
        src = fetchurl {      
          url = "https://download.jetbrains.com/cpp/CLion-${version}.tar.gz";
          sha256 = "0q9givi3w8q7kdi5y7g1pj4c7kb00a4v0fvry04zsahdq5lzkikh";
        };
      }))

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
