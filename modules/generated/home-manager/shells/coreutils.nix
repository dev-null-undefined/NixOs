{pkgs, ...}: {
  home.packages = with pkgs; [
    coreutils
    gnused
    bash
  ];
}
