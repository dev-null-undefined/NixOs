{pkgs, ...}: let
  # Seamless brightness control: drives the hardware backlight via brightnessctl
  # down to the ~1% hardware floor, then continues dimming in software via
  # wl-gammarelay-rs (a linear Brightness multiplier applied by the compositor).
  # Brightness-up restores software brightness to 100% before raising hardware.
  brightness-ctl = pkgs.writeShellScriptBin "brightness-ctl" ''
    set -euo pipefail

    HW_STEP=7      # hardware backlight step (% of max per keypress)
    SW_STEP=0.05   # software brightness step (below hardware floor)
    SW_FLOOR=0.10  # never go fully black (tunable)
    DEST=rs.wl-gammarelay
    OBJ=/
    IFACE=rs.wl.gammarelay

    # Fall back to 1.0 (full software brightness) if the gamma daemon isn't up
    # yet, so brightness keys still drive the hardware backlight instead of
    # aborting the whole script under `set -o pipefail`.
    sw_get() { ${pkgs.systemd}/bin/busctl --user get-property "$DEST" "$OBJ" "$IFACE" Brightness 2>/dev/null | ${pkgs.gawk}/bin/awk '{print $2}' || echo 1.0; }
    sw_set() { ${pkgs.systemd}/bin/busctl --user set-property "$DEST" "$OBJ" "$IFACE" Brightness d "$1"; }

    case "''${1:-}" in
      down)
        max=$(${pkgs.brightnessctl}/bin/brightnessctl max)
        cur=$(${pkgs.brightnessctl}/bin/brightnessctl get)
        min=$(( max / 100 )); [ "$min" -lt 1 ] && min=1   # ~1% hardware floor
        if [ "$cur" -gt "$min" ]; then
          ${pkgs.brightnessctl}/bin/brightnessctl set "$HW_STEP%-"
          new=$(${pkgs.brightnessctl}/bin/brightnessctl get)
          [ "$new" -lt "$min" ] && ${pkgs.brightnessctl}/bin/brightnessctl set "$min"
        else
          b=$(sw_get)
          t=$(${pkgs.gawk}/bin/awk -v b="$b" -v s="$SW_STEP" -v f="$SW_FLOOR" 'BEGIN{t=b-s; if(t<f)t=f; printf "%.2f", t}')
          sw_set "$t"
        fi
        ;;
      up)
        b=$(sw_get)
        if ${pkgs.gawk}/bin/awk -v b="$b" 'BEGIN{exit !(b<0.999)}'; then
          t=$(${pkgs.gawk}/bin/awk -v b="$b" -v s="$SW_STEP" 'BEGIN{t=b+s; if(t>1)t=1; printf "%.2f", t}')
          sw_set "$t"
        else
          ${pkgs.brightnessctl}/bin/brightnessctl set "$HW_STEP%+"
        fi
        ;;
      *)
        echo "usage: brightness-ctl {up|down}" >&2
        exit 1
        ;;
    esac
  '';
in {
  home.packages = [brightness-ctl];

  # Software dimming daemon: applies the Brightness multiplier via the
  # wlr-gamma-control protocol. WAYLAND_DISPLAY is imported into the systemd
  # user environment by startup.nix's `systemctl --user import-environment`.
  systemd.user.services.wl-gammarelay-rs = {
    Unit = {
      Description = "wl-gammarelay-rs (software brightness/gamma for Wayland)";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.wl-gammarelay-rs}/bin/wl-gammarelay-rs";
      Restart = "on-failure";
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
