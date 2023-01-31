{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./features/desktop/hyprland
    ./features/cli
    ./features/shells/zsh
    ./features/programs/default.nix
  ];

  # -----   ------
  #| DP-4| |eDP-1 |
  # -----   ------
  monitors = [
    {
      name = "DP-4";
      width = 1920;
      height = 1080;
      isPrimary = true;
      refreshRate = 144;
      x = 0;
      workspace = "1";
    }
    {
      name = "DP-3";
      width = 1920;
      height = 1080;
      isPrimary = true;
      refreshRate = 144;
      x = 0;
      workspace = "1";
    }
    {
      name = "eDP-1";
      width = 1920;
      height = 1080;
      refreshRate = 144;
      x = 1920;
      workspace = "2";
    }
  ];
}
