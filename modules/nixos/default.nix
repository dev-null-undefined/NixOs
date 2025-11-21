{
  grub-savedefault = import ./grub-savedefault.nix;
  hostname = import ./hostname.nix;
  domain = import ./domain.nix;
  wireguard = import ./wireguard.nix;
  http-services = import ./http-services.nix;
  generated = import ../generated/generator.nix {
    prefix = ["generated"];
    mainDir = ../generated/nixos;
  };
}
