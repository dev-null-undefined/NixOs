input: let
  aliases = import ../_aliases.nix input;
in
  (import ./functions.nix)
  + (import ./gdb-gcc-functions.nix)
  + (import ./nix-functions.nix aliases)
  + (import ./keybindings.nix)
  + (import ./edit-command-line.nix)
  + ''
    # Immediately report changes in background job status.
    setopt notify

    # Arrow-key driven autocomplete menu
    zstyle ':completion:*' menu select

    # Default promt settings if .p10k failes to load
    PROMPT='%F{green}%n%f@%F{magenta}%m%f %F{blue}%B%~%b%f %# '
    RPROMPT='[%F{yellow}%?%f]'
  ''
