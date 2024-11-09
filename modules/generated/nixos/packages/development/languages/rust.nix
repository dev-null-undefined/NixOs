{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # RUST
    # cargo
    # rustc

    # rustup

    (rust-bin.stable.latest.complete.override {
      targets = ["wasm32-wasi"];
    })
    wasm-pack
    wasm-bindgen-cli
    cargo-wasi

    wabt
  ];
}
