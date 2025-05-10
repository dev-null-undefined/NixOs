{
  inputs,
  pkgs,
  ...
}: let
  # With flakes:
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
in {
  programs.spicetify = {
    enable = true;
    enabledExtensions = with spicePkgs.extensions; [
      shuffle # shuffle+ (special characters are sanitized out of extension names)

      powerBar

      keyboardShortcut

      history

      randomBadToTheBoneRiff

      sectionMarker

      beautifulLyrics
    ];
    # theme = spicePkgs.themes.catppuccin;
    # colorScheme = "mocha";
  };
}
