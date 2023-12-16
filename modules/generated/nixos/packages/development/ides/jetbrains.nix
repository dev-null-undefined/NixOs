{pkgs, ...}: let
  ides' = with pkgs.master.jetbrains; [
    idea-ultimate
    phpstorm
    pycharm-professional
    webstorm
    clion
    rider
    datagrip
    rust-rover
  ];
  plugins' = [
    "github-copilot"
    "nixidea"
    "csv-editor"
  ];
  ides-with-plugins' = builtins.map (ide: pkgs.master.jetbrains.plugins.addPlugins ide plugins') ides';
in {
  #environment.systemPackages = ides-with-plugins' ++ [jdk gateway];
  environment.systemPackages =
    ides'
    ++ (with pkgs.master;
        (with jetbrains; [gateway]) ++ [android-studio]);
}
