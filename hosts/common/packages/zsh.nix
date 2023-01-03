{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  environment.systemPackages = with pkgs; [
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions

    # Cat with syntax highlight
    bat

    # fuzzy finders
    fzf
    broot

    # Better ls
    lsd

    # Flex spec sharing Utilities
    screenfetch
    neofetch
    cpufetch
    macchina

    # mariadb TUI server connector
    mycli

    # Funny programs
    nyancat
    pipes
    cmatrix
    sl
    lolcat
  ];
}
