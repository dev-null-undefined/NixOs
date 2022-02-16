{ config, pkgs, lib, ... }:

{
  config = lib.mkMerge [
    { environment.systemPackages = with pkgs; [ ranger ]; }
    (lib.mkIf config.services.xserver.enable {
      environment.systemPackages = with pkgs; [ python39Packages.ueberzug ];
    })
  ];
}
