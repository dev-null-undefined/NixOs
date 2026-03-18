{
  wayland.windowManager.hyprland.settings = {
    # To replicate “smart gaps” / “no gaps when only” from other WMs/Compositors, use
    # Ref https://wiki.hyprland.org/Configuring/Workspace-Rules/
    # "Smart gaps" / "No gaps when only"
    workspace = [
      "w[tv1], gapsout:0, gapsin:0"
      "f[1], gapsout:0, gapsin:0"
    ];
    windowrule = [
      "match:float 0, match:workspace w[tv1], border_size 0"
      "match:float 0, match:workspace w[tv1], rounding 0"
      "match:float 0, match:workspace f[1], border_size 0"
      "match:float 0, match:workspace f[1], rounding 0"
    ];
  };
}
