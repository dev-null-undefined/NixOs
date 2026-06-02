{
  config,
  lib,
  ...
}: let
  cfg = config.generated.hardware.wakeup-trim;

  mkRule = subsystem: kernel: label: ''
    # ${label}
    ACTION=="add", SUBSYSTEM=="${subsystem}", KERNEL=="${kernel}", ATTR{power/wakeup}="disabled"'';

  mkRules = subsystem: devices:
    lib.mapAttrsToList (kernel: label: mkRule subsystem kernel label) devices;

  rules = (mkRules "pci" cfg.pciDevices) ++ (mkRules "mhi" cfg.mhiDevices);
in {
  options = {
    pciDevices = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example = {
        "0000:00:14.0" = "USB xHCI controller";
        "0000:00:1c.6" = "PCIe RP7 (WWAN modem)";
      };
      description = ''
        PCI device wakeup overrides. Keys are device addresses (BDF form),
        values are human-readable labels emitted as comments in the generated
        udev rules. Useful for trimming spurious S0ix wakes from devices that
        should not wake the host (Wi-Fi, Thunderbolt, WWAN modem, etc.). Lid
        and power button continue to wake the system regardless.
      '';
    };

    mhiDevices = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example = {mhi0 = "Modem Host Interface (Quectel WWAN)";};
      description = "MHI bus devices to disable wakeup on, keyed by kernel name.";
    };
  };

  services.udev.extraRules = lib.concatStringsSep "\n" rules + "\n";
}
