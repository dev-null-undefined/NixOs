{
  grub-savedefault = import ./grub-savedefault.nix;
  hostname = import ./hostname.nix;
  isVm = import ./isVM;
  domain = import ./domain.nix;
  programming-languages = import ./programming-languages;
}
