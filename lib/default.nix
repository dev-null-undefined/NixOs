{
  inputs,
  self,
  ...
} @ args: let
  inherit (inputs.nixpkgs) lib;
  mkPkgs = pkgs: overlays: system:
    pkgs {
      inherit system overlays;
      config = {
        allowUnfree = true;
        nvidia.acceptLicense = true;

        #config.allowBroken = true;
        permittedInsecurePackages = [
          "electron-19.1.9"
          "electron-25.9.0"
          "dotnet-sdk-7.0.410"
          "dotnet-sdk-wrapped-7.0.410"
          "dotnet-sdk-6.0.428"
          "dotnet-runtime-6.0.36"
          "dotnet-sdk-wrapped-6.0.428"
        ];
      };
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
              ))
            (getAttrsPathsSep value sep))
          attrset)
        else [""];
    in
      {
        mkOverlay = {
          input ? inputs."nixpkgs-${name}",
          name,
          overlays ? [],
        }: (_final: prev: {
          "${name}" = mkPkgs (import input) overlays prev.pkgs.system;
        });

        groupIfExist = config: groups:
          builtins.filter (group: builtins.hasAttr group config.users.groups)
          groups;

        mkPkgsWithOverlays = system:
          mkPkgs (import inputs.nixpkgs)
          (lib.attrsets.mapAttrsToList (_: value: value) self.overlays)
          system;

        repeateString = string: count:
          lib.strings.concatMapStrings (_: string) (lib.lists.range 0 count);

        inherit getAttrsPathsSep;

        ifExists = file:
          if builtins.pathExists file
          then (import file)
          else {};

        getAttrsPaths = attrset: getAttrsPathsSep attrset ".";
      }
      // (import ./home-manager args)
      // (import ./nixos args);
  }
