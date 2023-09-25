{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # RUST
    # cargo
    # rustc

    # rustup

    rust-bin.stable.latest.complete
  ];
}
