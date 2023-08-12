{pkgs, ...}:
with pkgs.jetbrains; let
  ides' = [
    idea-ultimate
    phpstorm
    pycharm-professional
    webstorm
    clion
    rider
    datagrip
  ];
  plugins' = [
    "github-copilot"
  ];
  ides-with-plugins' = builtins.map (ide: plugins.addPlugins ide plugins') ides';
in {
  #environment.systemPackages = ides-with-plugins' ++ [jdk gateway];
  environment.systemPackages = ides' ++ [jdk gateway];
}
