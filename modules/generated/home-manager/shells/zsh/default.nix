{
  pkgs,
  lib',
  ...
}: {
  generated.home.shells.enable = lib'.mkDefault true;

  home.packages = with pkgs; [
    nomos-rebuild
    nix-output-monitor
  ];

  programs.zsh = {
    enable = true;

    dotDir = ".config/zsh";

    enableAutosuggestions = true;
    #enableSyntaxHighlighting = true;

    autocd = true;

    history = {
      extended = true;
      ignoreSpace = false;
      share = true;
      save = 10000000;
      size = 10000000;
    };

    profileExtra = ''
      setopt interactivecomments
    '';

    initExtra = import ./_extra {inherit lib';};

    shellAliases = import ./_aliases.nix {inherit lib';};

    localVariables = {
      TERM = "xterm-256color";
      EDITOR = "nvim";
      # Removed '/' from WORDCHARS so deleting single word removes just part of the path
      WORDCHARS = "*?_-.[]~=&;!#$%^(){}<>";
      # Using GPG agent for SSH authentication
      SSH_AUTH_SOCK = "/run/user/$UID/gnupg/S.gpg-agent.ssh";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
        "common-aliases"
        "docker"
        "docker-compose"
      ];
    };

    plugins = [
      rec {
        name = "fzf-tab";
        src = pkgs."zsh-${name}";
        file = "share/${name}/${name}.plugin.zsh";
      }
      rec {
        name = "fast-syntax-highlighting";
        src = pkgs."zsh-${name}";
        file = "share/zsh/site-functions/${name}.plugin.zsh";
      }
      rec {
        name = "powerlevel10k";
        src = pkgs."zsh-${name}";
        file = "share/zsh-${name}/${name}.zsh-theme";
      }
      rec {
        name = "forgit";
        src = pkgs."zsh-${name}";
        file = "share/zsh/zsh-${name}/${name}.plugin.zsh";
      }
      {
        name = "powerlevel10k-config";
        src = lib'.cleanSource ./p10k-config;
        file = "p10k.zsh";
      }
      {
        name = "insulter";
        src = lib'.cleanSource ./insulter;
        file = "insulter.sh";
      }
    ];
  };
}
