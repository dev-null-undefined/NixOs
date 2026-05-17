{...}: {
  boot.initrd.luks.devices.cryptroot = {
    device = "/dev/disk/by-uuid/6f544e34-1f1b-4f5b-9326-571f91e69fd4";
    allowDiscards = true;
    crypttabExtraOpts = ["tpm2-device=auto"];
  };

  boot.initrd.systemd.enable = true;
}
