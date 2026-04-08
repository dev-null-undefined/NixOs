{config, ...}: let
  monitors =
    builtins.filter (m: m != ",preferred,auto,1")
    config.wayland.windowManager.hyprland.settings.monitor;
  enableAll =
    builtins.concatStringsSep " ; " (map (m: "hyprctl keyword monitor \"${m}\"")
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
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };
}
