{
  pkgs,
  config,
  ...
}: let
  jetbrains =
    (
      import
      (fetchTarball {
        # Date: 20250713

        # https://github.com/NixOS/nixpkgs/issues/425328

        url = "https://github.com/NixOS/nixpkgs/tarball/9807714d6944a957c2e036f84b0ff8caf9930bc0";

        sha256 = "sha256:1g9qc3n5zx16h129dqs5ixfrsff0dsws9lixfja94r208fq9219g";
      })
      {
        config = {allowUnfree = true;};

        localSystem = {
          system = "x86_64-linux";
        };
      }
    ).jetbrains;

  ides' = with jetbrains; [
    idea-ultimate
    phpstorm
    pycharm-professional
    webstorm
    clion
    rider
    datagrip
    rust-rover
  ];
  plugins' = ["github-copilot" "nixidea" "csv-editor"];
  ides-with-plugins' =
    builtins.map (ide: jetbrains.plugins.addPlugins ide plugins') ides';
in {
  #environment.systemPackages = ides-with-plugins' ++ [jdk gateway];
  environment.systemPackages =
    ides'
    ++ [jetbrains.gateway pkgs.android-studio];
}
