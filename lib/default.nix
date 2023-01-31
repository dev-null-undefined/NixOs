{
  inputs,
  self,
  ...
} @ args: let

  lib = inputs.nixpkgs.lib;
  mkPkgs = pkgs: overlays: system:
    pkgs {
      inherit system;
      overlays = overlays;
      config.allowUnfree = true;
    };
in
  lib // {
    mkOverlay = {
      input ? inputs."nixpkgs-${name}",
      name,
      overlays ? [],
    }: (final: prev: {"${name}" = mkPkgs (import input) overlays prev.pkgs.system;});

    mkPkgsWithOverlays = system:
      mkPkgs (import inputs.nixpkgs)
      (lib.attrsets.mapAttrsToList (_: value: value) self.overlays)
      system;

    repeateString = with lib; string: count:
      strings.concatMapStrings
      (_: string)
      (lists.range 0 count);
  }
  // (import ./home-manager args)
  // (import ./nixos args)
