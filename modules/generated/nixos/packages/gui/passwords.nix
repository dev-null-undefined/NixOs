{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    bitwarden-desktop
    rofi-rbw-wayland
  ];
}
