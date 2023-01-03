{ pkgs, config, ... }:

{
  imports = [
    ./c.nix
    ./csharp.nix
    ./java.nix
    ./js.nix
    ./nix.nix
    ./php.nix
    ./python.nix
    ./rust.nix
  ];
}
