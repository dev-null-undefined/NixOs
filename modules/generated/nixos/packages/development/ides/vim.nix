{pkgs, ...}: {
  environment.systemPackages = with pkgs; [vim_configurable neovim];
}
