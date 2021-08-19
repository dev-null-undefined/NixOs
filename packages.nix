{ pkgs, ...}:

{
    programs.gnupg.agent.enable = true;
    programs.zsh.enable = true;

    environment.systemPackages = with pkgs; [
      papirus-icon-theme
      # ----- Terminal tools -----
      # TUI
      vim_configurable neovim
      ranger lynx
      htop bpytop glances gotop nload iftop
      mutt
      nyancat
      hyperfine
      # Commands
      lsd home-manager neofetch screenfetch tmux openssh gnumake tldr nmap
      most sshfs feh youtube-dl ffmpeg unzip zip gcc killall asciinema
      # Utilities
      wget curl git pandoc cmake light blueman fzf autorandr cron bat lolcat
      gnupg libnotify libinput-gestures hunspell aspell gspell xclip
      # zsh
      zsh zsh-autosuggestions zsh-syntax-highlighting zsh-completions
      # --------------------------

      # Notications deamon
      dunst

      # ======= GUI programms ======
      arandr alacritty dolphin gparted flameshot spotify pavucontrol
      gnome.gnome-power-manager firefox brave copyq lxappearance wireshark
      gimp shotcut vlc blender font-manager insomnia
      # Comunication
      discord
      # ===========================

      # ------- Programming -------
      # IDEs
      #    JetBrains
      jetbrains.idea-ultimate jetbrains.phpstorm jetbrains.clion jetbrains.jdk jetbrains.pycharm-professional

      vscode

      # Languages
      python2 jdk jdk8 php nodejs nodePackages.npm
      python37Full python37Packages.virtualenv python37Packages.pip python37Packages.setuptools
      python39Full python39Packages.virtualenv python39Packages.pip python39Packages.setuptools
      # --------------------------
  ];
  nixpkgs.config = {
      allowUnfree = true;
      #allowBroken = true;
  };

}
