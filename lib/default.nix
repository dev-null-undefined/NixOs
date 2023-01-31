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
  lib
  // {
    internal = let
      getAttrsPathsSep = attrset: sep:
        if builtins.isAttrs attrset && attrset != {}
        then
          lib.lists.flatten (lib.attrsets.mapAttrsToList (name: value:
            builtins.map (paths:
              name
              + (
                if paths != ""
                then sep + paths
                else ""
              )) (getAttrsPathsSep value sep))
          attrset)
        else [""];
    in
      {
        mkOverlay = {
          input ? inputs."nixpkgs-${name}",
          name,
          overlays ? [],
        }: (final: prev: {"${name}" = mkPkgs (import input) overlays prev.pkgs.system;});

        mkPkgsWithOverlays = system:
          mkPkgs (import inputs.nixpkgs)
          (lib.attrsets.mapAttrsToList (_: value: value) self.overlays)
          system;

        repeateString = string: count:
          lib.strings.concatMapStrings
          (_: string)
          (lib.lists.range 0 count);

        inherit getAttrsPathsSep;

        getAttrsPaths = attrset: getAttrsPathsSep attrset ".";
      }
      // (import ./home-manager args)
      // (import ./nixos args);
  }
