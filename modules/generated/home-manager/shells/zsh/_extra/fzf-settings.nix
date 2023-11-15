''
  export FZF_CTRL_T_OPTS="--preview '(bat -f --italic-text=always -n --line-range=:500 {} 2> /dev/null || tree -C {} || file {}) 2> /dev/null | head -200'"
  export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
''
