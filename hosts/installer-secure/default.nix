{
  imports = [
    ../installer/default.nix
  ];

  generated = {
    secure.enable = true;
    airgapped.enable = true;
  };
}
