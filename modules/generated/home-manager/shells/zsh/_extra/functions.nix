''
  btrfs-tree() {
      sudo btrfs subvol list / | cut -f9 -d' ' | sed -e 's/^/ROOT\//' | ~/user-tools/paths2indent | ~/user-tools/indent2tree
  }

  nvidia-offload() {
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
      exec "$@"
  }

  # # ex - archive extractor
  # # usage: ex <file>
  ex ()
  {
    if [ -f $1 ] ; then
      case $1 in
        *.tar.bz2)   tar xjf $1   ;;
        *.tar.gz)    tar xzf $1   ;;
        *.tar.xz)    tar xJf $1   ;;
        *.bz2)       bunzip2 $1   ;;
        *.rar)       unrar x $1     ;;
        *.gz)        gunzip $1    ;;
        *.tar)       tar xf $1    ;;
        *.tbz2)      tar xjf $1   ;;
        *.tgz)       tar xzf $1   ;;
        *.zip)       unzip $1     ;;
        *.Z)         uncompress $1;;
        *.7z)        7z x $1      ;;
        *)           echo "'$1' cannot be extracted via ex()" ;;
      esac
    else
      echo "'$1' is not a valid file"
    fi
  }

  fuck () {
      TF_PYTHONIOENCODING=$PYTHONIOENCODING;
      export TF_SHELL=zsh;
      export TF_ALIAS=fuck;
      TF_SHELL_ALIASES=$(alias);
      export TF_SHELL_ALIASES;
      TF_HISTORY="$(fc -ln -10)";
      export TF_HISTORY;
      export PYTHONIOENCODING=utf-8;
      TF_CMD=$(
          thefuck THEFUCK_ARGUMENT_PLACEHOLDER $@
      ) && eval $TF_CMD;
      unset TF_HISTORY;
      export PYTHONIOENCODING=$TF_PYTHONIOENCODING;
      test -n "$TF_CMD" && print -s $TF_CMD
  }

  tre() { command tre "$@" -e && source "/tmp/tre_aliases_$USER" 2>/dev/null; }

''
