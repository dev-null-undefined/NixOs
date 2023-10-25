# heavily inspired by https://github.com/hlissner/dotfiles hey command
let
  NIXOS_CURRENT_CONFIG = ../../../../../..;
  NIXOS_CONFIG_DIR = "/etc/nixos";
in ''
  hey-repl() {
    DIR=${NIXOS_CURRENT_CONFIG}
    if [[ "$1" == *-cur* ]]; then
      DIR=$(readlink ${NIXOS_CONFIG_DIR})
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

  hey-diff() {
    from=$(hey-gen | cut -d " " -f2)
    to=$(hey-gen | cut -d " " -f2)
    nix-diff /nix/var/nix/profiles/system-''${from}-link /nix/var/nix/profiles/system-''${to}-link "$@"
  }
''
