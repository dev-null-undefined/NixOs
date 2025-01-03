# heavily inspired by https://github.com/hlissner/dotfiles hey command
''
  hey-repl() {
    DIR=$(readlink -f "''${NIXOS_CONFIG_DIR}")
    if [[ "$1" == *-git* ]]; then
      DIR="''${NIXOS_CURRENT_CONFIG}"
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
    hey-gen | tr -s " " | cut -d " " -f2
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

  hey-factura() {
    home_l=`wc -c <<< ".$HOME"`
    faktura=`echo ~/Downloads/martinkos1-20??-??-??.pdf`
    report=`echo ~/Downloads/Clockify_Time_Report_Detailed_??_??_20??-??_??_20??.csv`
    faktura=`tail -c +$home_l <<< "$faktura"`
    report=`tail -c +$home_l <<< "$report"`
    fin_report=`tail -c +20 <<< "$report"`
    month=`sed -E 's/Downloads\/martinkos1-....-(..)-..\.pdf/\1/' <<< $faktura`
    year=`sed -E 's/Downloads\/martinkos1-(....)-..-..\.pdf/\1/' <<< $faktura`
    fin_dir="$HOME/Nextcloud/Work/CDN77/Faktury/$year/$month"
    mkdir -p $fin_dir
    mv ~/$faktura $fin_dir/
    mv ~/$report $fin_dir/$fin_report
  }

  hey-kitty() {
      PORT=''${1:=2222}
      COMMON='export TERM=xterm-256color;sleep 0.1;cd /sources;clear'
      BASH=' bash -i'
      kitty ssh root@localhost -p $PORT -o StrictHostKeyChecking=no -t "$COMMON;less -S +F /var/log/nginx/error.log" &
      kitty ssh root@localhost -p $PORT -o StrictHostKeyChecking=no -t "$COMMON;$BASH" &
      kitty ssh root@localhost -p $PORT -o StrictHostKeyChecking=no -t "$COMMON;$BASH" &
      ssh root@localhost -p $PORT -o StrictHostKeyChecking=no -t "$COMMON;less -S +F /var/log/nginx/access.shlog"
  }

''
