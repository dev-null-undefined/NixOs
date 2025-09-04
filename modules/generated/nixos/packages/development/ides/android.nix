{pkgs, ...}: {
  environment.systemPackages = with pkgs; [android-studio-full];
}
