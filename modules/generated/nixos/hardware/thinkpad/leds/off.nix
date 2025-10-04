{ config, lib, ... }:
{
  # Prevent enabling both on/off simultaneously
  assertions = [
    {
      assertion = !(lib.attrsets.attrByPath [
        "generated"
        "hardware"
        "thinkpad"
        "leds"
        "on"
        "enable"
      ] false config);
      message = "generated.hardware.thinkpad.leds.off conflicts with ...leds.on. Enable only one.";
    }
  ];

  systemd.tmpfiles.rules = [
    "w /sys/class/leds/tpacpi::lid_logo_dot/brightness - - - - 0"
    "w /sys/class/leds/tpacpi::power/brightness - - - - 0"
  ];
}

