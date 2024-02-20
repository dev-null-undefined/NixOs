{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    bitwarden
    rofi-rbw-wayland
  ];
}
