{
  pkgs,
  config,
  lib,
  ...
}: let
  # Dependencies
  htop = "${pkgs.htop}/bin/htop";
  btop = "${(pkgs.btop.override {cudaSupport = true;})}/bin/btop";
  iptraf-ng = "'/run/wrappers/bin/sudo ${pkgs.iptraf-ng}/bin/iptraf-ng'";
  powertop = "'/run/wrappers/bin/sudo ${pkgs.powertop}/bin/powertop'";
  nm-connection-editor = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
  nm-tui = ''"${pkgs.networkmanager}/bin/nmtui connect"'';

  ddcutil = "${pkgs.ddcutil}/bin/ddcutil";
  brightnessctl' = "${pkgs.brightnessctl}/bin/brightnessctl";

  brightnessScript = pkgs.writeShellScriptBin "brightness-control" ''
    set -euo pipefail

    CACHE="/tmp/waybar-brightness"
    DISPLAYS_CACHE="/tmp/waybar-brightness-displays"
    TARGET="/tmp/waybar-brightness-target"
    APPLY_LOCK="/tmp/waybar-brightness-lock"

    # Exponential step: fine control at low brightness, coarse at high
    get_step() {
      local val=$1
      if [ "$val" -le 5 ]; then echo 1
      elif [ "$val" -le 15 ]; then echo 2
      elif [ "$val" -le 30 ]; then echo 5
      elif [ "$val" -le 60 ]; then echo 10
      else echo 15
      fi
    }

    has_backlight() {
      [ -n "$(ls /sys/class/backlight/ 2>/dev/null)" ]
    }

    DDC_OPTS="--sleep-multiplier 0.03 --noverify"

    get_buses() {
      if [ -f "$DISPLAYS_CACHE" ]; then
        cat "$DISPLAYS_CACHE"
        return
      fi
      ${ddcutil} detect --brief 2>/dev/null | awk -F/ '/I2C bus:/{print $NF}' | sed 's/i2c-//' | tee "$DISPLAYS_CACHE"
    }

    get_first_bus() {
      get_buses | head -1
    }

    get_live() {
      if has_backlight; then
        ${brightnessctl'} -m -c backlight 2>/dev/null | awk -F, '{gsub(/%/,"",$4); print int($4)}'
      else
        local bus
        bus=$(get_first_bus)
        ${ddcutil} getvcp 10 --brief --bus "$bus" $DDC_OPTS 2>/dev/null | awk '{print int($4)}'
      fi
    }

    get_cached() {
      if has_backlight; then
        get_live
      elif [ -f "$CACHE" ] && [ -s "$CACHE" ]; then
        cat "$CACHE"
      else
        local val
        val=$(get_live)
        [ -n "$val" ] && echo "$val" > "$CACHE"
        echo "''${val:-0}"
      fi
    }

    set_brightness() {
      local val=$1
      if has_backlight; then
        ${brightnessctl'} set "''${val}%" > /dev/null
      else
        echo "$val" > "$CACHE"
        echo "$val" > "$TARGET"
        # Debounced apply: flock ensures only one applier runs at a time.
        # Rapid scrolls just update TARGET and exit; the running applier
        # picks up the latest value after each DDC write cycle.
        (
          flock -n 9 || exit 0
          while true; do
            sleep 0.3
            val=$(cat "$TARGET")
            echo "$val" > "$CACHE"
            while IFS= read -r bus; do
              [ -n "$bus" ] && ${ddcutil} setvcp 10 "$val" --bus "$bus" $DDC_OPTS 2>/dev/null &
            done < <(get_buses)
            wait
            [ "$(cat "$TARGET")" = "$val" ] && break
          done
        ) 9>"$APPLY_LOCK" &
        disown
      fi
    }

    case "''${1:-get}" in
      get)
        val=$(get_cached)
        val=''${val:-0}
        if [ "$val" -le 25 ]; then icon="󰃞"
        elif [ "$val" -le 50 ]; then icon="󰃟"
        else icon="󰃠"
        fi
        printf '{"text": "%s %s%%", "tooltip": "Brightness: %s%%", "percentage": %s}\n' "$icon" "$val" "$val" "$val"
        ;;
      up)
        val=$(get_cached)
        val=''${val:-50}
        step=$(get_step "$val")
        new=$(( val + step ))
        [ "$new" -gt 100 ] && new=100
        set_brightness "$new"
        ;;
      down)
        val=$(get_cached)
        val=''${val:-50}
        step=$(get_step "$val")
        new=$(( val - step ))
        [ "$new" -lt 0 ] && new=0
        set_brightness "$new"
        ;;
    esac
  '';

  terminal = "${pkgs.kitty}/bin/kitty";
  terminal-spawn = cmd: "${terminal} $SHELL -i -c ${cmd}";

  # Script to toggle battery charging behavior and print a message
  toggleCharge = pkgs.writeShellScriptBin "toggle-battery-charging" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail

    BAT_PATH="/sys/class/power_supply/BAT0/charge_control_end_threshold"
    current="$(cat "$BAT_PATH" 2>/dev/null || true)"

    if [ "''${current}" = "100" ]; then
      action="setcharge"
      message="Resetting to default charging thresholds"
    else
      action="fullcharge"
      message="Full charging now"
    fi

    /run/wrappers/bin/sudo ${pkgs.tlp}/bin/tlp "''${action}"
    echo "''${message}"
    ${pkgs.libnotify}/bin/notify-send "Battery" "''${message}"
  '';

  systemMonitor = terminal-spawn htop;
  systemMonitor2 = terminal-spawn btop;
  networkMonitor = terminal-spawn iptraf-ng;
  powerMonitor = terminal-spawn powertop;
  networkManager = terminal-spawn nm-tui;

  isSway = config.generated.home.desktop.sway.enable;
  isHyprland = config.generated.home.desktop.hyprland.enable;
in {
  programs.waybar = {
    enable = true;
    settings = {
      primary = {
        layer = "top";
        margin = "3";
        position = "bottom";
        exclusive = true;
        modules-left =
          ["clock" "cpu" "memory"]
          ++ (lib.lists.optionals isSway ["sway/workspaces"])
          ++ (lib.lists.optionals isHyprland ["hyprland/workspaces"]);
        modules-center =
          []
          ++ (lib.lists.optionals isSway ["sway/window"])
          ++ (lib.lists.optionals isHyprland ["hyprland/window"]);

        modules-right = [
          "tray"
          "battery"
          "network#wl"
          "network#en"
          "custom/brightness"
          "pulseaudio"
          "pulseaudio#microphone"
        ];
        "sway/workspaces" = {
          format = "{name} {icon}";
          format-icons = {
            "urgent" = "";
            "active" = "";
            "default" = "";
          };
        };
        "sway/window" = {
          format = "{title}";
          max-length = 50;
          rewrite = {
            "(.*) \\S+ Mozilla Firefox" = "🌎 $1";
            "nvim (.*)" = " $1";
            "martin@idk:(.*)" = " [$1]";
          };
        };
        "hyprland/workspaces" = {
          format = "{name} {icon}";
          on-click = "activate";
          format-icons = {
            "urgent" = "";
            "active" = "";
            "default" = "";
          };
          sort-by-number = true;
        };
        "hyprland/window" = {
          format = "{title}";
          rewrite = {
            "(.*) \\S+ Mozilla Firefox" = "🌎 $1";
            "n?vim (.*)" = " $1";
          };
          separate-outputs = true;
        };
        clock = {
          format = "{:%d-%m-%Y (%R)}  ";
          format-alt = "{:%H:%M}  ";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            on-click-right = "mode";
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>W{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
          actions = {on-click-right = "mode";};
        };
        cpu = {
          format = " {usage}%";
          on-click = systemMonitor;
        };
        memory = {
          format = " {}%";
          format-alt = " {used:0.1f}G";
          interval = 5;
          on-click = systemMonitor2;
        };
        battery = {
          bat = "BAT0";
          interval = 10;
          format-icons = ["" "" "" "" "" "" "" "" "" ""];
          format = "{icon} {capacity}% (-{power:.1f}w)";
          format-charging = " {capacity}% ({power:.1f}w)";
          format-plugged = "🔌︎{capacity}%";
          on-click = powerMonitor;
          on-click-right = "${toggleCharge}/bin/toggle-battery-charging";
        };
        "network#en" = {
          interface = "en*";
          interval = 1;
          format = "{ifname}";
          format-ethernet = " {ipaddr}/{cidr}";
          format-disconnected = "";
          tooltip-format = ''
            {ipaddr}/{cidr}
            Up:   {bandwidthUpBits:>10}
            Down: {bandwidthDownBits:>10}'';
          tooltip-format-disconnected = "Disconnected";
          on-click = networkMonitor;
          on-click-right = nm-connection-editor;
        };
        "network#wl" = {
          interface = "wl*";
          interval = 1;
          format = "{ifname}";
          format-wifi = " {essid}";
          format-disconnected = "";
          tooltip-format = ''
            {essid} ({signalStrength}%) 
            {ipaddr}/{cidr}
            Up:   {bandwidthUpBits:>10}
            Down: {bandwidthDownBits:>10}'';
          tooltip-format-disconnected = "Disconnected";
          on-click = networkMonitor;
          on-click-right = nm-connection-editor;
        };
        "custom/brightness" = {
          format = "{}";
          return-type = "json";
          exec = "${brightnessScript}/bin/brightness-control get";
          on-scroll-up = "${brightnessScript}/bin/brightness-control up";
          on-scroll-down = "${brightnessScript}/bin/brightness-control down";
          interval = 2;
        };
        "pulseaudio#microphone" = {
          format = "{format_source}";
          format-source = " {volume}%";
          format-source-muted = " Muted";
          on-click = "pamixer --default-source -t";
          on-scroll-up = "pamixer --default-source -i 5 --allow-boost";
          on-scroll-down = "pamixer --default-source -d 5 --allow-boost";
        };
        pulseaudio = {
          format = "{icon}  {volume}%";
          on-click = "pamixer -t";
          on-scroll-up = "pamixer -i 5 --allow-boost";
          on-scroll-down = "pamixer -d 5 --allow-boost";
          format-muted = "   0%";
          format-icons = {
            headphone = "";
            headset = "";
            portable = "";
            default = ["" "" ""];
          };
        };
      };
    };
    style = builtins.readFile ./waybar-style.css;
  };
}
