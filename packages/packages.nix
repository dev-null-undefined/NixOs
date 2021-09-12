{ pkgs, ... }:

{
    imports =
      [
        ./common.nix
        ./zsh.nix
        ./games.nix
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
      most sshfs feh youtube-dl ffmpeg unzip zip asciinema
      imagemagick
      # Utilities
      pandoc light blueman fzf autorandr cron bat lolcat
      libnotify libinput-gestures hunspell aspell gspell xclip
      coreutils
      # --------------------------

      # Notications deamon
      dunst

      # ======= GUI programms ======
      spotify
      firefox brave chromium
      copyq lxappearance wireshark
      gimp-with-plugins vlc shotcut vlc blender
      font-manager ark 
      dolphin gnome.nautilus pcmanfm 
      gparted flameshot pavucontrol arandr
      insomnia mysql-workbench alacritty
      # Comunication
      discord
      # ===========================

      # ------- Programming -------
      # IDEs
      #    JetBrains
      jetbrains.idea-ultimate jetbrains.phpstorm jetbrains.clion jetbrains.jdk jetbrains.pycharm-professional

      vscode

      # Spell checking
      hunspell
      hunspellDicts.en-us hunspellDicts.cs-cz
  ];
  nixpkgs.config = {
      allowUnfree = true;
      #allowBroken = true;
  };

}
