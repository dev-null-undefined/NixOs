{
  pkgs,
  config,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # JavaScript
    nodejs
    nodePackages.npm
    yarn
  ];
}
