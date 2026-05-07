{pkgs, ...}: {
  environment.systemPackages = with pkgs; [karere];
}
