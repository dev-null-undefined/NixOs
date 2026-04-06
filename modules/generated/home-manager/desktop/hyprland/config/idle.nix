{config, ...}: let
  # Monitors that need disabling instead of DPMS (NVIDIA HDMI FRL link training
  # fails on DPMS resume, freezing the compositor). Using monitor disable/enable
  # does a full modeset which avoids the FRL re-negotiation bug.
  monitors =
    builtins.filter (m: m != ",preferred,auto,1")
    config.wayland.windowManager.hyprland.settings.monitor;
  disableAll = builtins.concatStringsSep " ; " (map (m:
    let
      desc = builtins.head (builtins.split "," m);
    in "hyprctl keyword monitor \"${desc},disable\"")
  monitors);
  enableAll = builtins.concatStringsSep " ; " (map (m:
    "hyprctl keyword monitor \"${m}\"")
  monitors);
in {
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = enableAll;
      };

      listener = [
        # Lock screen after 10 minutes
        {
          timeout = 600;
          on-timeout = "loginctl lock-session";
        }
        # Turn off monitors after 15 minutes (OLED burn-in protection)
        {
          timeout = 900;
          on-timeout = disableAll;
          on-resume = enableAll;
        }
      ];
    };
  };
}
