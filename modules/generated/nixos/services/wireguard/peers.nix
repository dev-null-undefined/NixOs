{
  networking.wireguard.interfaces.wg0.peers = [
    # List of allowed peers.
    {
      # RPI home-assistant brnikov
      publicKey = "IYujtBpTlBBZ2hzv6P6BDQqm9hOAizitkPN4YvnOpxE=";
      allowedIPs = ["10.100.0.2/32"];
      persistentKeepalive = 25;
    }
  ];
}
