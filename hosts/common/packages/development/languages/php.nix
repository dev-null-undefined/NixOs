{ pkgs, config, ... }:

{
  environment.systemPackages = with pkgs;
    [
      # php
      php
    ];
}
