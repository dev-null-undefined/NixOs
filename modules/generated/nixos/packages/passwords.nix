{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    rbw
    bitwarden-cli
  ];
}
