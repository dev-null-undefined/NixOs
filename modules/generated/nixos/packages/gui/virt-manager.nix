{pkgs, ...}: {
  virtualisation = {
    libvirtd.enable = true;
    vmware = {
      guest.enable = true;
    };
  };
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [virt-manager];
}
