{ pkgs, config, ... }:

{
  environment.systemPackages = with pkgs; [
    # lsp server for nix
    nil
    # Nix formatter
    nixfmt
  ];
}
