{
  config,
  lib,
  pkgs,
  ...
}: let
  # Dependencies
  htop = "${pkgs.htop}/bin/htop";
  ikhal = "${pkgs.stable.khal}/bin/ikhal";
  nm-connection-editor = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
  nm-tui = ''"${pkgs.networkmanager}/bin/nmtui connect"'';

  terminal = "${pkgs.kitty}/bin/kitty";
  terminal-spawn = cmd: "${terminal} $SHELL -i -c ${cmd}";

  calendar = terminal-spawn ikhal;
  systemMonitor = terminal-spawn htop;
  networkManager = terminal-spawn nm-tui;
in {
  programs.waybar = {
    enable = true;
    package = pkgs.waybar-hyprland;
    settings = {
      primary = {
        layer = "top";
        margin = "3";
        position = "bottom";
        exclusive = true;
        modules-left = [
          "clock"
          "cpu"
          "memory"
          "wlr/workspaces" # TODO: better way of switching between hyprland and sway
          "sway/workspaces"
        ];
        modules-center = [
          "hyprland/window"
          "sway/window"
        ];
        modules-right = [
          "tray"
          "battery"
          "network#wlo"
          "network#enp"
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
        "wlr/workspaces" = {
          format = "{name} {icon}";
          on-click = "activate";
          format-icons = {
            "urgent" = "";
            "active" = "";
            "default" = "";
          };
          sort-by-number = true;
        };
        clock = {
          format = "{: %R   %d/%m}";
          tooltip-format = ''
            <big>{:%Y %B}</big>
            <tt><small>{calendar}</small></tt>'';
          on-click = calendar;
        };
        cpu = {
          format = " {usage}%";
          on-click = systemMonitor;
        };
        memory = {
          format = " {}%";
          format-alt = " {used:0.1f}G";
          interval = 5;
          on-click = systemMonitor;
        };
        battery = {
          bat = "BAT1";
          interval = 10;
          format-icons = ["" "" "" "" "" "" "" "" "" ""];
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          onclick = "";
        };
        "network#enp" = {
          interface = "enp*";
          interval = 3;
          format = "{ifname}";
          format-ethernet = " {ipaddr}/{cidr}";
          format-disconnected = "";
          tooltip-format = ''
            {ipaddr}/{cidr}
            Up: {bandwidthUpBits}
            Down: {bandwidthDownBits}'';
          tooltip-format-disconnected = "Disconnected";
          on-click = networkManager;
          on-click-right = nm-connection-editor;
        };
        "network#wlo" = {
          interface = "wlo*";
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
          on-click = networkManager;
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
