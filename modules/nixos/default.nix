{
  grub-savedefault = import ./grub-savedefault.nix;
  hostname = import ./hostname.nix;
  isVm = import ./isVM;
  domain = import ./domain.nix;
  wireguard = import ./wireguard.nix;
  generated = import ../generated/generator.nix {
    prefix = ["generated"];
    mainDir = ../generated/nixos;
  };
}
