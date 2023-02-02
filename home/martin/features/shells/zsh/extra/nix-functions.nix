aliases: let
  NIXOS_CURRENT_CONFIG = ../../../../../..;
  NIXOS_CONFIG_DIR = "/etc/nixos";
in ''

  export NIXOS_CONFIG_DIR="$(realpath '${NIXOS_CONFIG_DIR}')"
  export NIXOS_CURRENT_CONFIG="${NIXOS_CURRENT_CONFIG}"

  sudo-nom-rebuild-fallback() {
    if ! command -v nom-rebuild &>/dev/null; then
      sudo nixos-rebuild "$@"
    else
      sudo nom-rebuild "$@"
    fi
  }

  nix-update() {
    sudo nix flake update "''${NIXOS_CONFIG_DIR}"
    if [ $? -eq 0 ]; then
      nix-rebuild "$@"
      if [ $? -eq 0 ]; then
        git --git-dir="''${NIXOS_CONFIG_DIR}/.git" --work-tree="''${NIXOS_CONFIG_DIR}" add "''${NIXOS_CONFIG_DIR}/flake.lock"
      fi
    fi
  }

  nix-tre() {
    nix-tree "${NIXOS_CURRENT_CONFIG}#$1"
  }

  nix-rebuild() {
    sudo-nom-rebuild-fallback switch --flake "''${NIXOS_CONFIG_DIR}#" "$@"
  }

  nix-rebuild-boot() {
    sudo-nom-rebuild-fallback boot --flake "''${NIXOS_CONFIG_DIR}#" "$@"
  }

  nix-find() {
    printf "%s\n" $(nix eval --raw "${NIXOS_CURRENT_CONFIG}#$1.outPath" 2>/dev/null)
  }

  nix-path() {
    nix-find "$1"
  }

  nix-pkg() {
    pkgs=()
    hostname=$(hostname)

    while (($#)); do
      pkg="$1"

      shift

      if [[ "$pkg" == "--" ]]; then
        break
      fi

      pkgs+=("${NIXOS_CURRENT_CONFIG}#''${pkg}")
    done

    if [ $# -gt 0 ]; then
      nix shell "''${pkgs[@]}" -c "''${@}"
    else
      nix shell "''${pkgs[@]}"
    fi
  }

  function _nix-pkg() {
    local ifs_bk="$IFS"
    local input=("''${(Q)words[-1]}")
    IFS=$'\n'
    local res=($(NIX_GET_COMPLETIONS=2 nix run $NIXOS_CONFIG_DIR"#""$input[@]" 2>/dev/null))
    IFS="$ifs_bk"
    local tpe="''${''${res[1]}%%>	*}"
    local -a suggestions
    declare -a suggestions
    for suggestion in ''${res:1}; do
      # Remove the common path
      package=''${''${(@s/#/)suggestion}:1}
      suggestions+=("''${package%%	*}")
    done
    local -a args
    if [[ "$tpe" == filenames ]]; then
      args+=('-f')
    elif [[ "$tpe" == attrs ]]; then
      args+=('-S' ''')
    fi
    compadd -J nix "''${args[@]}" -a suggestions
  }

  compdef _nix-pkg nix-pkg

  compdef nix-path=nix-pkg
  compdef nix-find=nix-pkg
  compdef nix-tre=nix-pkg

  center-text() {
    text="''${@}"
    width=$(tput cols)

    # Calculate the number of dashes needed
    dashes=$(printf '%.s─' $(seq 1 ''${width}))

    # Calculate the number of spaces needed to center the text
    spaces=$(((''${width} - ''${#text}) / 2))

    # Add spaces before and after the text to center it
    centered_text=$(printf "%''${spaces}s%s%''${spaces}s" " " "''${text}" " ")

    # Display the horizontal line with text in the center
    echo "''${dashes}"
    echo "''${centered_text}"
    echo "''${dashes}"
  }

  nix-eval() {
    hostname=$(hostname)

    while (($#)); do
      option="$1"

      shift
      
      center-text nix eval ${NIXOS_CURRENT_CONFIG}#nixosConfigurations.''${hostname}.''${option}
      nix eval ${NIXOS_CURRENT_CONFIG}#nixosConfigurations.''${hostname}.''${option}

    done
  }

  function _nix-custom-eval() {
    hostname=$(hostname)
    local ifs_bk="$IFS"
    local input=("''${(Q)words[-1]}")
    IFS=$'\n'
    local res=($(NIX_GET_COMPLETIONS=2 nix eval ''${NIXOS_CONFIG_DIR}"#nixosConfigurations."''${hostname}".$input[@]" 2>/dev/null))
    IFS="$ifs_bk"
    local tpe="''${''${res[1]}%%>	*}"
    local -a suggestions
    declare -a suggestions
    for suggestion in ''${res:1}; do
      # Remove the common path
      option=''${''${''${(@s/#/)suggestion}:1}##nixosConfigurations.''${hostname}.}
      suggestions+=("''${option%%	*}")
    done
    local -a args
    if [[ "$tpe" == filenames ]]; then
      args+=('-f')
    elif [[ "$tpe" == attrs ]]; then
      args+=('-S' ''')
    fi
    compadd -J nix "''${args[@]}" -a suggestions
  }

  compdef _nix-custom-eval nix-eval

  ngrep() {
    ${aliases.sgrep} "$*" "${NIXOS_CURRENT_CONFIG}"
  }

  manyx() {
    manix "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | fzf --preview="manix '{}'" | xargs manix
  }

''
