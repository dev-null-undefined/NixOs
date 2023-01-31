{pkgs, ...}: {
  virtualisation = {
    libvirtd.enable = true;
    virtualbox.host = {
      enable = true;
      enableHardening = false;
    };
  };
  programs.dconf.enable = true;
  hardware.opengl.enable = true;
  environment.systemPackages = with pkgs; [virt-manager];
}
