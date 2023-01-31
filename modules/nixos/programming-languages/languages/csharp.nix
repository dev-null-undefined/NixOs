{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf (config.programming-languages.languages.csharp.enable or false) {
  environment.systemPackages = with pkgs; [
    # C#
    dotnet-sdk
    mono
    msbuild
  ];
}
