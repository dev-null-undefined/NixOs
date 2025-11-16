{pkgs, ...}: {
  environment.systemPackages = with pkgs; [vim-full neovim];
}
