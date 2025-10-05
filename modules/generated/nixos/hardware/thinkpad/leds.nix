{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.generated.hardware.thinkpad.leds;

  setLedsScript = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      name: value: "echo ${toString value.brightness} > /sys/class/leds/${name}/brightness"
    )
    cfg.segments
  );
in {
  options = {
    defaultBrightness = lib.mkOption {
      type = lib.types.enum [0 1];
      default = 0;
      description = "Default brightness for all LEDs.";
    };

    segments = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options.brightness = lib.mkOption {
            type = lib.types.enum [0 1];
            default = cfg.defaultBrightness;
            description = "Brightness of the LED. 0 = off, 1 = on.";
          };
        }
      );
      default = {
        "tpacpi::lid_logo_dot" = {};
        "tpacpi::power" = {};
      };
      description = "Configuration for each LED. The name of the attr is the LED name from /sys/class/leds/.";
    };
  };

  systemd.tmpfiles.rules =
    lib.mapAttrsToList (
      name: value: "w /sys/class/leds/${name}/brightness - - - - ${toString value.brightness}"
    )
    cfg.segments;

  powerManagement.resumeCommands = setLedsScript;
}
