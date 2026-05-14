{lib, ...}: {
  generated.services = {
    acme.enable = lib.mkDefault true;
    tailscale.enable = lib.mkDefault true;
    fwupd.enable = lib.mkDefault true;
  };
}
