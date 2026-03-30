{
  inputs,
  config,
  ...
}: {
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = config.system.primaryUser;
    autoMigrate = true;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
    mutableTaps = true;
  };

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    masApps = {
      WireGuard = 1451685025;
    };
  };
}
