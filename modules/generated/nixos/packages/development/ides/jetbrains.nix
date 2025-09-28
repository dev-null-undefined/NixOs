{pkgs, ...}: let
  inherit (pkgs.master) jetbrains;

  ides' = with jetbrains; [
    idea-ultimate
    phpstorm
    pycharm-professional
    webstorm
    pkgs.stable.jetbrains.clion
    rider
    datagrip
    rust-rover
    gateway
  ];
  plugins' = [
    "github-copilot"
    "nixidea"
    "csv-editor"
  ];
  ides-with-plugins' = builtins.map (ide: jetbrains.plugins.addPlugins ide plugins') ides';
in {
  #environment.systemPackages = ides-with-plugins' ++ [jdk gateway];
  environment.systemPackages =
    ides'
    ++ [
      jetbrains.gateway
      pkgs.android-studio
    ];
}
