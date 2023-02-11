{
  config,
  lib,
  pkgs,
  ...
}: let
  # Dependencies
  htop = "${pkgs.htop}/bin/htop";
  ikhal = "${pkgs.khal}/bin/ikhal";
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
          "wlr/workspaces"
        ];
        modules-center = [
          "hyprland/window"
        ];
        modules-right = [
          "tray"
          "battery"
          "network#wlo"
          "network#enp"
          "pulseaudio"
          "pulseaudio#microphone"
        ];
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
    style = ''
      * {
          border: none;
          border-radius: 0;
          font-family: Cartograph CF Nerd Font, monospace;
          font-weight: bold;
          font-size: 14px;
          min-height: 0;
      }

      window#waybar {
          background: rgba(21, 18, 27, 0);
          color: #cdd6f4;
      }

      tooltip {
          background: #1e1e2e;
          border-radius: 10px;
          border-width: 2px;
          border-style: solid;
          border-color: #11111b;
      }

      #workspaces button {
          padding: 5px;
          color: #313244;
          margin-right: 5px;
      }

      #workspaces button.active {
          color: #a6adc8;
      }

      #workspaces button.focused {
          color: #a6adc8;
          background: #eba0ac;
          border-radius: 10px;
      }

      #workspaces button.urgent {
          color: #11111b;
          background: #a6e3a1;
          border-radius: 10px;
      }

      #workspaces button:hover {
          background: #11111b;
          color: #cdd6f4;
          border-radius: 10px;
      }

      #custom-language,
      #custom-updates,
      #custom-caffeine,
      #custom-weather,
      #cpu,
      #memory,
      #window,
      #clock,
      #battery,
      #pulseaudio,
      #network,
      #workspaces,
      #tray,
      #backlight {
          background: #1e1e2e;
          padding: 0px 10px;
          margin: 3px 0px;
          margin-top: 5px;
          border: 1px solid #181825;
      }

      #tray {
          border-radius: 10px;
          margin-right: 10px;
      }

      #workspaces {
          background: #1e1e2e;
          border-radius: 10px;
          margin-left: 10px;
          padding-right: 0px;
          padding-left: 5px;
      }

      #custom-caffeine {
          color: #89dceb;
          border-radius: 10px 0px 0px 10px;
          border-right: 0px;
          margin-left: 10px;
      }

      #custom-language {
          color: #f38ba8;
          border-left: 0px;
          border-right: 0px;
      }

      #custom-updates {
          color: #f5c2e7;
          border-left: 0px;
          border-right: 0px;
          border-radius: 10px 0px 0px 10px;;
      }

      #window {
          border-radius: 10px;
          margin-left: 60px;
          margin-right: 60px;
      }

      #clock {
          color: #fab387;
          border-radius: 10px 0px 0px 10px;
          margin-left: 5px;
          border-right: 0px;
      }

      #network {
          color: #f9e2af;
          border-left: 0px;
          border-right: 0px;
      }

      #pulseaudio {
          color: #89b4fa;
          border-left: 0px;
          border-right: 0px;
      }

      #pulseaudio.microphone {
          color: #cba6f7;
          margin-right: 5px;
          border-radius: 0 10px 10px 0;
      }

      #battery {
          color: #a6e3a1;
          border-radius: 10px 0 0 10px;
          border-left: 0px;
          border-right: 0px;
      }

      #custom-weather {
          border-radius: 0px 10px 10px 0px;
          border-right: 0px;
          margin-left: 0px;
      }

      #memory,
      #cpu {
          border-right: 0px;
          border-left: 0px;
      }

      #memory {
          border-radius: 0 10px 10px 0;
      }
    '';
  };
}
