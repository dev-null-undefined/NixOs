{
  stdenvNoCC,
  nixos-rebuild,
  lib,
  nix-output-monitor,
  ...
}: let
  nixos-rebuild' = nixos-rebuild.overrideAttrs (_: prev: {
    path =
      (lib.makeBinPath [
        nix-output-monitor
      ]);
  });
in
  stdenvNoCC.mkDerivation {
    name = "nomos-rebuild";

    src = nixos-rebuild';

    patches = [./nomos-rebuild.patch];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp bin/nixos-rebuild $out/bin/nomos-rebuild
      runHook postInstall
    '';
  }
