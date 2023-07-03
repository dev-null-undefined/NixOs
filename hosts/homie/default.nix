# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{...}: {
  generated.services.ssh.enable = true;

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;

  # networking.enableIPv6 = true;
  networking.useDHCP = true;

  system.stateVersion = "22.11"; # Did you read the comment?
}
