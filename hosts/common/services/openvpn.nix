{ pkgs, ... }:

{
  services.openvpn.servers = {
    serverVPS = { config = "config /root/NixOs-server.ovpn "; };
  };
}
