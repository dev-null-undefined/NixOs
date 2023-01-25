{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf (config.programming-languages.languages.rust.enable or false) {
  environment.systemPackages = with pkgs; [
    # RUST
    cargo
    rustc
  ];
}
