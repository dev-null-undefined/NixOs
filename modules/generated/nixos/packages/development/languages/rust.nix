{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # RUST
    # cargo
    # rustc

    # rustup

    (rust-bin.stable.latest.complete.override {
      targets = ["wasm32-wasip2" "wasm32-wasip1" "wasm32-unknown-unknown"];
    })
    wasm-pack
    wasm-bindgen-cli
    cargo-wasi

    wabt
  ];
}
