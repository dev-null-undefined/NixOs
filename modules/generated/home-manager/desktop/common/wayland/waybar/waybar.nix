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

  terminal = "${pkgs.kitty}/bin/kitty";
  terminal-spawn = cmd: "${terminal} $SHELL -i -c ${cmd}";

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
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          on-click = powerMonitor;
        };
        "network#en" = {
          interface = "en*";
          interval = 3;
          format = "{ifname}";
          format-ethernet = " {ipaddr}/{cidr}";
          format-disconnected = "";
          tooltip-format = ''
            {ipaddr}/{cidr}
            Up: {bandwidthUpBits}
            Down: {bandwidthDownBits}'';
          tooltip-format-disconnected = "Disconnected";
          on-click = networkMonitor;
          on-click-right = nm-connection-editor;
        };
        "network#wl" = {
          interface = "wl*";
          interval = 3;
          format = "{ifname}";
          format-wifi = " {essid}";
          format-disconnected = "";
          tooltip-format = ''
            {essid} ({signalStrength}%) 
            {ipaddr}/{cidr}
            Up: {bandwidthUpBits}
            Down: {bandwidthDownBits}'';
          tooltip-format-disconnected = "Disconnected";
          on-click = networkMonitor;
          on-click-right = nm-connection-editor;
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
