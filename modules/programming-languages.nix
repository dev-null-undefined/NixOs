{
  lib,
  config,
  ...
}:
with lib; let
  allLanguages = attrsets.filterAttrs (key: _: key != "default.nix" && strings.hasSuffix ".nix" key) (builtins.readDir ../hosts/common/packages/development/languages);
  languageOption = with types; {
    options.enable = mkOption {
      type = bool;
      default = true;
      description = "If given tools for language should be enabled";
    };
  };
in {
  options.programming-languages = mkOption {
    type = with types; attrsOf (submodule languageOption);
    description = "Hostname of the current system";
  };

  config.programming-languages = attrsets.mapAttrs' (name: value: nameValuePair (strings.removeSuffix ".nix" name) {enable = mkDefault true;}) allLanguages;
}
