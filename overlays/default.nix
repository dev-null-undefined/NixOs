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
  #
  # Built from the *stable* hyprlock (via final.stable, so it is independent of
  # overlay application order): the hyprland flake overlay pins hyprutils to a
  # post-0.13.1 git snapshot that made CSharedPointer's `operator bool`
  # explicit, which fails to compile hyprlock 0.9.5 ("cannot convert
  # CSharedPointer<CCWlSeat> to bool"). nixpkgs-stable's hyprlock 0.9.5 builds
  # against stable's matching hyprutils 0.13.1. Revisit once unstable's hyprlock
  # catches up to the newer hyprutils API.
  hyprlock-no-retry-cap = final: super: {
    hyprlock = final.stable.hyprlock.overrideAttrs (old: {
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
      # AppArmor 5.0.0 on unstable ships a broken aa-remove-unknown: it sources
      # apparmor-parser's lib/apparmor/rc.apparmor.functions, which 5.0.0 no
      # longer installs, so apparmor.service's ExecReload fails on switch. Pin
      # parser+utils+profiles to stable 4.1.7 until unstable is fixed (profiles
      # must match the parser, or their check phase rejects 5.0.0-only syntax).
      # Not libapparmor — that's linked by systemd and would force a
      # system-wide rebuild.
      apparmor-parser
      apparmor-profiles
      apparmor-utils
      bat-extras
      batgrep
      # freecad 1.1.1's postInstall does `substituteInPlace ... --replace-fail
      # "TryExec=freecad-thumbnailer"` on FreeCAD.thumbnailer, but that pattern
      # isn't in the installed file → build dies. Same buggy expr on all
      # channels, so source builds fail everywhere; only stable has a cached
      # prebuilt binary. Pin to stable (fetches the binary, skips the rebuild).
      freecad
      # GDAL 3.13.1 on unstable const-ified its CSL string-list API
      # (CSLConstList, was char**). Reverse-deps that still pass char** fail to
      # compile: pdal 2.9.3 (Raster.cpp) and vtk 9.5.2 (vtkGDALRasterReader.cxx),
      # breaking vtk → freecad on x1/xps. Pin GDAL to stable 3.12.4 (old API) to
      # fix the whole fallout at the root; gdalMinimal follows via gdal.override.
      # Unpin once unstable's pdal+vtk adopt the const API.
      gdal
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

  # Betaflight Configurator 10.10.0 targets nwjs's legacy NW1 window mode (its
  # manifest sets `--disable-features=nw2` and it calls nwNatives.getRoutingID).
  # nixpkgs runs it on nwjs 0.102.1 (Chromium 139), which removed NW1 — the
  # toolbar renders but the content pane stays blank. Pin the app to nwjs 0.68.1
  # (Chromium 105), the runtime Betaflight's own portable build ships. See
  # https://github.com/NixOS/nixpkgs/issues/305779.
  betaflight-nwjs-pin = final: super: {
    betaflight-configurator = super.betaflight-configurator.override {
      nwjs = super.nwjs.overrideAttrs (_: rec {
        version = "0.68.1";
        src = super.fetchurl {
          url = "https://dl.nwjs.io/v${version}/nwjs-v${version}-linux-x64.tar.gz";
          hash = "sha256-M4Fk+qVI4fTTLCTSDO8sYQa6F+sWglUhlTaW5/zytWg=";
        };
        # Chromium 105 cannot load this system's Wayland client libraries. The
        # stock nwjs wrapper adds --ozone-platform-hint=auto when NIXOS_OZONE_WL
        # is set (Hyprland session), so it exits with "Failed to initialize
        # Wayland platform". Force XWayland instead — this nwjs is used only by
        # betaflight-configurator, so scoping it here is safe.
        preFixup = ''
          gappsWrapperArgs+=( --add-flags "--ozone-platform=x11" )
        '';
      });
    };
  };

  rust-overlay = inputs.rust-overlay.overlays.default;

  # Build darktable against a rawspeed carrying Sony A7R VI (ILCE-7RM6) ARW6
  # (TIFF compression 32766) decode support by swapping in the patched tree.
  darktable-arw6 = final: super: {
    darktable = super.darktable.overrideAttrs (old: {
      postPatch =
        (old.postPatch or "")
        + ''
          rm -rf src/external/rawspeed
          cp -r --no-preserve=mode,ownership ${inputs.rawspeed-arw6}/. src/external/rawspeed
        '';
    });
  };
}
