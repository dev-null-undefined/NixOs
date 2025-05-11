{ config, pkgs, lib, ... }:

{

  # Setup transmission
  services.transmission = {
    enable = true;
    settings = {
      port-forwarding-enabled = false;
      rpc-authentication-required = true;
      rpc-port = 9091;
      rpc-bind-address = "0.0.0.0";
      rpc-username = "admin";
      # This is a salted hash of the real password
      # https://github.com/tomwijnroks/transmission-pwgen
      rpc-password = "{51475e881d2ddc772ebb0843eb9a42b4af7c49726pyJCFa6";
      # rpc-host-whitelist = hostnames.transmission; Reverse proxy stuff
      
      rpc-host-whitelist-enabled = false;
      # rpc-whitelist = lib.mkDefault "127.0.0.1"; # Overwritten by Cloudflare
      rpc-whitelist-enabled = false;
    };
  };

  # Bind transmission to wireguard namespace
  # TODO route through VPN

  # Caddy and Transmission both try to set rmem_max for larger UDP packets.
  # We will choose Transmission's recommendation (4 MB).
  # boot.kernel.sysctl."net.core.rmem_max" = 4194304;

}
