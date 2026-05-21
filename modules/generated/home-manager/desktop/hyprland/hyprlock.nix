{pkgs, ...}: let
  layoutScript = pkgs.writeShellScriptBin "hyprlock-layout" ''
    layout=$(${pkgs.hyprland}/bin/hyprctl devices -j 2>/dev/null \
      | ${pkgs.jq}/bin/jq -r '[.keyboards[] | select(.main==true)] | first | .active_keymap // "??"')
    case "$layout" in
      "English (US)") echo "󰌌 US" ;;
      "Czech"*) echo "󰌌 CZ" ;;
      *) echo "󰌌 $layout" ;;
    esac
  '';
in {
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
      };

      background = [
        {
          path = ""; # solid color - screenshot+blur causes NVIDIA freezes
          color = "rgb(191724)"; # rose-pine base
        }
      ];

      input-field = [
        {
          size = "400, 60";
          outline_thickness = 3;
          dots_size = 0.33;
          dots_spacing = 0.15;
          dots_center = true;
          outer_color = "rgb(191724)";
          inner_color = "rgb(1f1d2e)";
          font_color = "rgb(e0def4)";
          fade_on_empty = true;
          placeholder_text = "<i>Password...</i>";
          hide_input = false;
          check_color = "rgb(eb6f92)";
          fail_color = "rgb(31748f)";
          fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
          position = "0, -20";
          halign = "center";
          valign = "center";
        }
      ];

      label = [
        # Time
        {
          text = "cmd[update:1000] date +\"%H:%M\"";
          color = "rgb(e0def4)";
          font_size = 90;
          font_family = "Inter";
          position = "0, 150";
          halign = "center";
          valign = "center";
        }
        # Date
        {
          text = "cmd[update:1000] date +\"%d.%m.%Y\"";
          color = "rgb(e0def4)";
          font_size = 24;
          font_family = "Inter";
          position = "0, 70";
          halign = "center";
          valign = "center";
        }
        {
          text = "cmd[update:500] ${layoutScript}/bin/hyprlock-layout";
          color = "rgb(fab387)";
          font_size = 18;
          font_family = "Cartograph CF Nerd Font";
          position = "0, -110";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
