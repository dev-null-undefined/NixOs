{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf (config.programming-languages.rust.enable) {
  environment.systemPackages = with pkgs; [
    # RUST
    cargo
    rustc
  ];
}
