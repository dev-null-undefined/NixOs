{ pkgs, ...}:

{
  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    zsh
    zsh-autosuggestions zsh-syntax-highlighting zsh-completions
  ];
}
