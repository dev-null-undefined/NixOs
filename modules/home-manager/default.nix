{
  generated = import ../generated/generator.nix {
    prefix = ["generated" "home"];
    mainDir = ../generated/home-manager;
  };
}
