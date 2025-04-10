{ pkgs, lib', inputs, ... }:
let
  history-sync-git = pkgs.fetchFromGitHub {
    owner = "dev-null-undefined";
    repo = "history-sync";
    rev = "f72e2bdd8286b3a816ef6463c7d60d85a9460645";
    hash = "sha256-xNo5Mqt4irHkQDEExgXmoGNGM0+7oSML3XMyKnwIBN0=";
  };
in {
  home.packages = with pkgs; [ nix-output-monitor zoxide lsd ];

  programs.zsh = {
    enable = true;

    dotDir = ".config/zsh";

    autosuggestion.enable = true;
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

    initExtra = import ./_extra { inherit lib' pkgs inputs; };

    shellAliases = import ./_aliases.nix { inherit lib' pkgs; };

    localVariables = {
      TERM = "xterm-256color";
      EDITOR = "nvim";
      # Removed '/' from WORDCHARS so deleting single word removes just part of the path
      WORDCHARS = "*?_-.[]~=&;!#$%^(){}<>";
      # Using GPG agent for SSH authentication
      SSH_AUTH_SOCK = "/run/user/$UID/gnupg/S.gpg-agent.ssh";
      # History sync variables
      ZSH_HISTORY_GIT_REMOTE =
        "https://github.com/dev-null-undefined/history-sync-zsh.git";
      ZSH_HISTORY_COMMIT_MSG = "`hostname`[$USER]: `date -u '+%H:%M %d-%m-%Y'`";
      ZSH_HISTORY_DEFAULT_RECIPIENT = "Martin Kos";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "common-aliases" "docker" "docker-compose" ];
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
      {
        name = "history-sync";
        src = history-sync-git;
        file = "history-sync.plugin.zsh";
      }
    ];
  };
}
