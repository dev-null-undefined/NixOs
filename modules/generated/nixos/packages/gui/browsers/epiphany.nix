{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    epiphany
  ];
}
