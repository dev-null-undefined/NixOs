{
  inputs,
  self,
}:
with self.lib'.internal; {
  stable = mkOverlay {name = "stable";};
  dev-null = mkOverlay {name = "dev-null";};
  master = mkOverlay {name = "master";};
  custom-packages = import ../pkgs;
  wep_wpa_supplicant_fix = import ./wep_wpa_supplicant_fix.nix;
  waybar-bandwidth-fix = import ./waybar-bandwidth-fix.nix;
  hyprland = inputs.nixpkgs.lib.composeManyExtensions [
    inputs.hyprland.overlays.hyprland-packages
    inputs.hyprland.overlays.hyprland-extras
  ];
  hyprland-contrib = inputs.hyprland-contrib.overlays.default;

  stable-pkgs = final: super: {
    inherit
      (super.stable)
      bat-extras
      batgrep
      glances # test failing on oracle-server host, due to aarch architecture
      hyprlock # 0.9.3 SIGSEGVs in CShader dtor when init fails, deadlocking session lock
      lutris
      qbittorrent # qBit 5.2.0 SIGSEGV in Http::Connection::acceptsGzipEncoding on Qt 6.11.0 (upstream issue #24038, no fix yet). stable ships qtbase 6.10.2, pre-regression.
      qbittorrent-nox
      wineWowPackages
      ;
    inherit (super.dev-null) rpi-imager;
  };

  # direnv 2.37.1 test suite hangs/OOMs on macOS during fish/zsh scenarios;
  # disable checkPhase so the package builds locally.
  direnv-skip-tests = final: super: {
    direnv = super.direnv.overrideAttrs (_: {
      doCheck = false;
    });
  };

  master-pkgs = final: super: {
    inherit
      (super.master)
      flaresolverr
      kodi
      discord
      jetbrains
      claude-code
      ;
  };

  rust-overlay = inputs.rust-overlay.overlays.default;
}
