{pkgs, ...}: let
  # Outputs nothing on systems without a battery, so the label widget stays blank.
  batteryScript = pkgs.writeShellScriptBin "hyprlock-battery" ''
    shopt -s nullglob
    bats=(/sys/class/power_supply/BAT*)
    [ ''${#bats[@]} -eq 0 ] && exit 0
    bat="''${bats[0]}"
    cap=$(<"$bat/capacity")
    status=$(<"$bat/status")
    if [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
      icon="󰂄"
    elif [ "$cap" -ge 90 ]; then icon="󰁹"
    elif [ "$cap" -ge 80 ]; then icon="󰂂"
    elif [ "$cap" -ge 70 ]; then icon="󰂁"
    elif [ "$cap" -ge 60 ]; then icon="󰂀"
    elif [ "$cap" -ge 50 ]; then icon="󰁿"
    elif [ "$cap" -ge 40 ]; then icon="󰁾"
    elif [ "$cap" -ge 30 ]; then icon="󰁽"
    elif [ "$cap" -ge 20 ]; then icon="󰁼"
    elif [ "$cap" -ge 10 ]; then icon="󰁻"
    else icon="󰁺"
    fi
    echo "$icon $cap%"
  '';
in {
  programs.hyprlock.settings.label = [
    {
      text = "cmd[update:10000] ${batteryScript}/bin/hyprlock-battery";
      color = "rgb(e0def4)";
      font_size = 18;
      font_family = "Cartograph CF Nerd Font";
      position = "-40, 40";
      halign = "right";
      valign = "bottom";
    }
  ];
}
