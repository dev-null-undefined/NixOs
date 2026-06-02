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
  programs.hyprlock.settings.label = [
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
}
