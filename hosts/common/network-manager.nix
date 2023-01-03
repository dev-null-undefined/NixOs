{
  config,
  pkgs,
  inputs,
  ...
}: {
  networking = {
    networkmanager.enable = true;
    useDHCP = false;
  };
}
