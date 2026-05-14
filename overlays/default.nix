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
      wineWowPackages
      ;
    inherit (super.dev-null) rpi-imager;
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
