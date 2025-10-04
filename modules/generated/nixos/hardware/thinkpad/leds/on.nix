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
        "off"
        "enable"
      ] false config);
      message = "generated.hardware.thinkpad.leds.on conflicts with ...leds.off. Enable only one.";
    }
  ];

  systemd.tmpfiles.rules = [
    "w /sys/class/leds/tpacpi::lid_logo_dot/brightness - - - - 1"
    "w /sys/class/leds/tpacpi::power/brightness - - - - 1"
  ];
}

