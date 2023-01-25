{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf (config.programming-languages.csharp.enable) {
  environment.systemPackages = with pkgs; [
    # C#
    dotnet-sdk
    mono
    msbuild
  ];
}
