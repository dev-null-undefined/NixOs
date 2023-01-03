{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [ vim_configurable neovim ];
}
