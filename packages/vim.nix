{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    vim_configurable
    neovim
    # lsp server for nix
    nil
    # lsb server for C++
    ccls
  ];
}
