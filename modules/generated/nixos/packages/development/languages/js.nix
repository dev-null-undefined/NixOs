{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # JavaScript
    nodejs
    yarn
    bun
  ];
}
