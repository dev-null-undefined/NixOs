{ pkgs, ... }:

let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in {
    imports =
      [
        ./common.nix
        ./zsh.nix
        ./games.nix
        ./discord.nix
      ];
    environment.systemPackages = with pkgs; [
      papirus-icon-theme
      # ----- Terminal tools -----
      # TUI
      lynx
      bpytop glances gotop nload iftop nethogs
      mutt
      nyancat
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
      gimp-with-plugins vlc blender shotcut
      font-manager ark 
      dolphin gnome.nautilus pcmanfm 
      gparted flameshot pavucontrol arandr
      insomnia alacritty mysql-workbench

      # ------- Programming -------
      # IDEs
      #    JetBrains
      jetbrains.idea-ultimate jetbrains.phpstorm jetbrains.clion jetbrains.jdk jetbrains.pycharm-professional

      vscode

      # Spell checking
      hunspell
      hunspellDicts.en-us hunspellDicts.cs-cz

      # Libs
      xorg.libX11 xorg.libXinerama xorg.libXft imlib2

      # dev tools
      valgrind

      # FIT - TZP
      unstable.mathematica
  ];
  nixpkgs.config = {
      allowUnfree = true;
      #allowBroken = true;
  };

}
