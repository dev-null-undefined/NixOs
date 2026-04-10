{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.generated.home.desktop.hyprland.config.idle;

  # Monitors that need disabling instead of DPMS (NVIDIA HDMI FRL link training
  # fails on DPMS resume, freezing the compositor). Using monitor disable/enable
  # does a full modeset which avoids the FRL re-negotiation bug.
  monitors =
    builtins.filter (m: m != ",preferred,auto,1")
    config.wayland.windowManager.hyprland.settings.monitor;
  disableAll = builtins.concatStringsSep " ; " (map (m: let
    desc = builtins.head (builtins.split "," m);
  in "hyprctl keyword monitor \"${desc},disable\"")
  monitors);
  enableAll =
    builtins.concatStringsSep " ; " (map (m: "hyprctl keyword monitor \"${m}\"")
      monitors);

  offCmd =
    if cfg.useDpms
    then "hyprctl dispatch dpms off"
    else disableAll;
  onCmd =
    if cfg.useDpms
    then "hyprctl dispatch dpms on"
    else enableAll;

  sleepMonitors = pkgs.writeShellScriptBin "sleep-monitors" ''
    loginctl lock-session
    sleep 0.5
    ${offCmd}
    # Re-enable monitors once hyprlock exits (user unlocked)
    (
      while ${pkgs.procps}/bin/pidof hyprlock > /dev/null 2>&1; do
        sleep 0.5
      done
      sleep 0.2
      ${onCmd}
    ) &
  '';
in {
  options = {
    useDpms = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use DPMS off/on instead of monitor disable/enable for idle timeout. Disable/enable does a full modeset which works around NVIDIA HDMI FRL link training failures on DPMS resume.";
    };
  };

  home.packages = [sleepMonitors];

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = onCmd;
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
          on-timeout = offCmd;
          on-resume = onCmd;
        }
      ];
    };
  };
}
