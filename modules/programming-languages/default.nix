{
  lib,
  config,
  ...
}:
with lib; let
  allLanguages = attrsets.filterAttrs (key: _: key != "default.nix" && strings.hasSuffix ".nix" key) (builtins.readDir ./.);
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
    ./c.nix
    ./csharp.nix
    ./java.nix
    ./js.nix
    ./nix.nix
    ./php.nix
    ./python.nix
    ./rust.nix
    ./verilog.nix
  ];

  config = mkIf (config.programming-languages.enable) {
    programming-languages.languages = attrsets.mapAttrs' (name: value: nameValuePair (strings.removeSuffix ".nix" name) {enable = mkDefault config.programming-languages.defaultLanguageValue;}) allLanguages;
  };
}
