{
  lib,
  config,
  ...
}:
with lib; let
  allLanguageFiles = builtins.readDir ./languages;
  allLanguages = attrsets.mapAttrsToList (key: _: strings.removeSuffix ".nix" key) allLanguageFiles;
  languageOption = with types; {
    options.enable = mkOption {
      type = bool;
      description = "If given tools for language should be enabled";
    };
  };
in {
  options.programming-languages = {
    languages = mkOption {
      type = with types; attrsOf (submodule languageOption);
      default = {};
      description = "Set of languageOption submodule.";
    };

    enable = mkEnableOption "Programming languages";

    defaultLanguageValue = mkOption {
      type = types.bool;
      default = true;
      description = "Default value that will be set for each language.";
    };
  };

  imports = [
    ./languages/c.nix
    ./languages/csharp.nix
    ./languages/java.nix
    ./languages/js.nix
    ./languages/nix.nix
    ./languages/php.nix
    ./languages/python.nix
    ./languages/rust.nix
    ./languages/verilog.nix
  ];

  config = mkIf (config.programming-languages.enable) {
    programming-languages.languages = builtins.foldl' (acc: language:
      acc // {"${language}".enable = mkDefault config.programming-languages.defaultLanguageValue;}) {}
    allLanguages;
  };
}
