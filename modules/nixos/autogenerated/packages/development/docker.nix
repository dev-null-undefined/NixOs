{
  config,
  pkgs,
  lib,
  ...
}: {
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };
  environment.systemPackages = with pkgs; [
    docker-compose
    lazydocker # tui for managing dockers
  ];
}
