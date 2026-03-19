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
  hyprland = inputs.hyprland.overlays.default;
  hyprland-contrib = inputs.hyprland-contrib.overlays.default;

  stable-pkgs = super: final: {
    inherit
      (super.stable)
      bitwarden-desktop
      webcord
      godot_4
      pixelorama
      firefox
      libreoffice
      thunderbird
      carla
      blender
      easyeffects
      shotcut
      gimp-with-plugins
      # davinci-resolve
      audacity
      clisp
      lldb
      darktable
      batgrep
      bat-extras
      copyq
      nextcloud-client
      lutris
      wine
      wineWowPackages
      kcat
      freecad
      mycli
      ;
    inherit (super.dev-null) rpi-imager;
  };

  master-pkgs = super: final: {
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
