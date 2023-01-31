{
  programs.fzf.enable = true;
  programs.z-lua = {
    enable = true;
    enableAliases = true;
    options = ["enhanced" "once" "fzf"];
  };

  programs.broot = {
    enable = true;
  };
}
