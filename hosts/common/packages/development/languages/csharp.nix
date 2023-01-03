{
  pkgs,
  config,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # C#
    dotnet-sdk
    mono
    msbuild
  ];
}
