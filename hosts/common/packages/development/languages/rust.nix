{ pkgs, config, ... }:

{
  environment.systemPackages = with pkgs; [
    # RUST
    cargo
    rustc
  ];

}
