{ pkgs, ...}:

{

  environment.systemPackages = with pkgs; [
    jetbrains.idea-ultimate jetbrains.phpstorm jetbrains.jdk jetbrains.pycharm-professional jetbrains.webstorm
      (pkgs.jetbrains.clion.overrideAttrs (old: rec{
        version = "2021.2.2";
        src = fetchurl {
          url = "https://download.jetbrains.com/cpp/CLion-${version}.tar.gz";
          sha256 = "0q9givi3w8q7kdi5y7g1pj4c7kb00a4v0fvry04zsahdq5lzkikh";
        };
      }))
  ];
}
