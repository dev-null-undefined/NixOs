{
  # To sync local tracks from your filesystem with mobile devices in the same network,
  # you need to open port 57621 by adding the following line to your configuration.nix:
  networking.firewall.allowedTCPPorts = [57621];
  # In order to enable discovery of Google Cast devices (and possibly other Spotify Connect devices)
  # in the same network by the Spotify app, you need to open UDP port 5353 by adding the following line to your
  networking.firewall.allowedUDPPorts = [5353];
}
