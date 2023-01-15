{inputs}: let
  mkPkgs = pkgs: overlays: system:
    pkgs {
      inherit system;
      overlays = overlays;
      config.allowUnfree = true;
    };

  mkOverlay = {
    input ? inputs."nixpkgs-${name}",
    name,
    overlays ? [],
    system,
  }: (final: prev: {"${name}" = mkPkgs (import input) overlays system;});
in {
  inherit mkPkgs;

  overlays = system: [
    (mkOverlay {
      inherit system;
      name = "stable";
    })
    (mkOverlay {
      inherit system;
      name = "dev-null";
    })
    (mkOverlay {
      inherit system;
      name = "testing";
    })
    (mkOverlay {
      inherit system;
      name = "master";
    })
    (mkOverlay {
      inherit system;
      name = "webcord";
    })
    (import ../pkgs)
  ];
}
