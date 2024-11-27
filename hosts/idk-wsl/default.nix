# Help is available in the default.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

  wsl.enable = true;
  wsl.defaultUser = "martin";

  wsl.wslConf.network.generateResolvConf = false;

  networking.nameservers = ["1.1.1.1" "8.8.8.8"];

  documentation.man.generateCaches = false;

  system.stateVersion = "23.05"; # Did you read the comment?
}
