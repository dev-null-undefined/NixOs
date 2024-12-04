{lib, ...}: {
  generated.network-profiles = {
    vpn.enable = lib.mkDefault true;
    wifi.enable = lib.mkDefault true;
  };
  networking.networkmanager.ensureProfiles.environmentFiles = ["/var/secrets/network-manager.env"];
}
