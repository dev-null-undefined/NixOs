{
  inputs,
  self,
}:
with self.lib'.internal; {
  stable = mkOverlay {
    name = "stable";
  };
  dev-null = mkOverlay {
    name = "dev-null";
  };
  master = mkOverlay {
    name = "master";
  };
  custom-packages = import ../pkgs;
  hyprland = inputs.hyprland.overlays.default;
  hyprland-contrib = inputs.hyprland-contrib.overlays.default;

  rust-overlay = inputs.rust-overlay.overlays.default;
}
