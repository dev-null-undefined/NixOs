{ pkgs, ... }:

{
  # Disable networking so the system is air-gapped
  # Comment all of these lines out if you'll need internet access
  boot.initrd.network.enable = false;
  networking.dhcpcd.enable = false;
  networking.dhcpcd.allowInterfaces = [ ];
  networking.interfaces = { };
  networking.firewall.enable = true;
  networking.useDHCP = false;
  networking.useNetworkd = false;
  networking.wireless.enable = false;
  networking.networkmanager.enable = pkgs.lib.mkForce false;
}

