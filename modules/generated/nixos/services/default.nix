{lib, ...}: {
  generated.services = {
    acme.enable = lib.mkDefault true;
    tailscale.enable = lib.mkDefault true;
  };
}
