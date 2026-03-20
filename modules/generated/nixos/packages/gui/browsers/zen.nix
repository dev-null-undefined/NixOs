{
  inputs,
  config,
  ...
}: {
  environment.systemPackages = [inputs.zen-browser.packages.${config.nixpkgs.hostPlatform.system}.default];
}
