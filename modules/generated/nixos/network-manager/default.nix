{pkgs, ...}: {
  networking = {
    networkmanager = {
      enable = true;
      plugins = with pkgs; [networkmanager-openvpn];
    };
    useDHCP = false;
  };
  generated.network-manager = {
    network-profiles.enable = true;
    dont-wait.enable = true;
  };
}
