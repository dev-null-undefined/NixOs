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

  # Lift hyprlock's hard-coded 3-attempt fingerprint cap. Upstream offers no
  # config knob for this; see https://github.com/hyprwm/hyprlock/issues/711.
  hyprlock-no-retry-cap = final: super: {
    hyprlock = super.hyprlock.overrideAttrs (old: {
      postPatch =
        (old.postPatch or "")
        + ''
          substituteInPlace src/auth/Fingerprint.cpp \
            --replace-fail "m_sDBUSState.retries >= 3" "m_sDBUSState.retries >= 9999"
        '';
    });
  };

  stable-pkgs = final: super: {
    inherit
      (super.stable)
      bat-extras
      batgrep
      glances # test_phys_core_returns_int fails on aarch64-linux (oracle-server) — phys_core() returns None
      hyprlock # 0.9.3 SIGSEGVs in CShader dtor when init fails, deadlocking session lock
      lutris
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
