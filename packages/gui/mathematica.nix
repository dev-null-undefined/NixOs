{ pkgs, ... }:

let
  version = "12.3.1";
  lang = "en";
in {
  environment.systemPackages = with pkgs;
    [
      # FIT - TZP
      (pkgs.dev-null.mathematica.overrideAttrs (old: {
        version = version;
        lang = lang;
        language = "English";
        name = "mathematica-${version}"
          + lib.optionalString (lang != "en") "-${lang}";
        src = requireFile rec {
          name = "Mathematica_${version}"
            + lib.optionalString (lang != "en") "_${language}" + "_LINUX.sh";
          message = ''
            This nix expression requires that ${name} is
            already part of the store. Find the file on your Mathematica CD
            and add it to the nix store with nix-store --add-fixed sha256 <FILE>.
          '';
          sha256 =
            "51b9cab12fd91b009ea7ad4968a2c8a59e94dc55d2e6cc1d712acd5ba2c4d509";
        };
      }))
    ];
}
