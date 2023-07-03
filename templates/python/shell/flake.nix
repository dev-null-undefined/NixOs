{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      python-packages = ps:
        with ps; [
          pandas
          requests
          numpy
          pytest
          hypothesis
          typing-extensions
        ];
      my-python = pkgs.python39.withPackages python-packages;
    in {
      devShells.default = my-python.env;
      packages = pkgs // {custom-python = my-python;};
    });
}
