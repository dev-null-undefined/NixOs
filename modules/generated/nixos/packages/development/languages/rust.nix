{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # RUST
    cargo
    rustc
  ];
}
