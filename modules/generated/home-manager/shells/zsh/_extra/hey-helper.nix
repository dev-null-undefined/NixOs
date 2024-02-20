# heavily inspired by https://github.com/hlissner/dotfiles hey command
let
  NIXOS_CURRENT_CONFIG = ../../../../../..;
  NIXOS_CONFIG_DIR = "/etc/nixos";
in ''
  hey-repl() {
    DIR=$(readlink -f ${NIXOS_CONFIG_DIR})
    if [[ "$1" == *-git* ]]; then
      DIR=${NIXOS_CURRENT_CONFIG}
      shift
    fi
    tmp="$(mktemp)"
    echo "(builtins.getFlake \"$DIR\")" > $tmp
    nix repl --file "$tmp" "$@"
    rm -f "$tmp"
  }

  hey-gc() {
    sudo nix-collect-garbage -d
    # nix-collect-garbage is a Nix tool, not a NixOS tool. It won't delete old
    # boot entries until you do a nixos-rebuild (which means we'll always have
    # 2 boot entries at any time). Instead, we properly delete them by
    # reloading the current environment.
    sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
  }

  hey-gen() {
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | fzf --tac
  }

  hey-gen-id() {
    hey-gen | cut -d " " -f3
  }

  hey-gen-path() {
    echo /nix/var/nix/profiles/system-`hey-gen-id`-link
  }

  hey-nvd() {
    nvd diff `hey-gen-path` `hey-gen-path`
  }

  hey-diff() {
    nix-diff `hey-gen-path` `hey-gen-path` "$@"
  }

  hey-port() {
    echo "Use nixos-firewall-tool lol"
  }

''
