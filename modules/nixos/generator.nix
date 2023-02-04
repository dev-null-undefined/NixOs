{
  self,
  pkgs,
  ...
} @ outerArgs: let
  lib = self.lib;

  mainDir = ./autogenerated;

  getAllFiles = dir: lib.filesystem.listFilesRecursive dir;

  filterNixFiles = files: builtins.filter (file: lib.strings.hasSuffix ".nix" file) files;

  pathSplit = path: lib.strings.splitString "/" path;
  pathToModuleParts = path: pathSplit (lib.strings.removeSuffix ".nix" (builtins.toString path));

  removeCommonPart = parts: lib.lists.drop (builtins.length (pathToModuleParts mainDir)) parts;

  mkNixKeyPath = path: {
    inherit path;
    parts = removeCommonPart (pathToModuleParts path);
  };

  mkNixKeyPaths = files:
    builtins.map mkNixKeyPath
    files;

  nixKeyPathsToFolders = keyPaths:
    builtins.map (keyPath: mkNixKeyPath (builtins.dirOf keyPath.path))
    keyPaths;

  getNixKeyPaths = dir: mkNixKeyPaths (filterNixFiles (getAllFiles dir));

  generateOption = keyPath:
    {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "From: ${keyPath.path},TODO create a way to define description inside of the attrset without having to do many modifications.";
      };
    }
    // (
      if (builtins.length keyPath.parts) == 0
      then {}
      else {
        "${builtins.head keyPath.parts}" = generateOption {
          parts = builtins.tail keyPath.parts;
          inherit (keyPath) path;
        };
      }
    );

  generateConfig = {
    keyPath,
    configPath ? keyPath.parts,
  }: {config, ...}: {
    config =
      lib.mkIf (lib.attrsets.attrByPath (configPath ++ ["enable"]) false config)
      ((import (keyPath.path)) outerArgs);
  };

  generateFolderConfig = folder: let
    subNixKeyPaths = getNixKeyPaths folder.path;
  in
    builtins.map (keyPath:
      generateConfig {
        inherit keyPath;
        configPath = folder.parts;
      })
    subNixKeyPaths;

  nixKeyPaths = getNixKeyPaths mainDir;

  foldersKeyPaths = nixKeyPathsToFolders nixKeyPaths;
in {
  options = builtins.foldl' (acc: keyPath: lib.attrsets.recursiveUpdate (generateOption keyPath) acc) {} nixKeyPaths;
  imports = (builtins.map (keyPath: generateConfig {inherit keyPath;}) nixKeyPaths) ++ (builtins.concatMap (folder: generateFolderConfig folder) foldersKeyPaths);
}