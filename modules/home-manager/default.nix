{
  generated = import ../generated/generator.nix {
    prefix = ["generated" "home"];
    mainDir = ../generated/home-manager;
  };
  p10k = import ./p10k.nix;
}
