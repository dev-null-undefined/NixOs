{
  hostname = import ../nixos/hostname.nix;
  generated = import ../generated/generator.nix {
    prefix = ["generated"];
    mainDir = ../generated/darwin;
  };
}
