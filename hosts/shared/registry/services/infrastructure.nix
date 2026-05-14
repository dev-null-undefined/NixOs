{
  registry.services = {
    adguard = {
      host = "homie";
      port = 3380;
    };
    adguard-dns = {
      host = "homie";
      port = 53;
    };
    prometheus = {
      host = "homie";
      port = 9001;
    };
    victorialogs = {
      host = "homie";
      port = 9428;
    };
    ntopng = {
      host = "homie";
      port = 3001;
    };
    influxdb2 = {
      host = "homie";
      port = 8086;
    };
    harmonia = {
      host = "homie";
      port = 5000;
      internalPort = 5001;
    };
    atuin = {
      host = "homie";
      port = 8888;
      subdomain = "atuin";
    };
    minecraft-voice = {
      host = "homie";
      port = 33665;
    };
  };
}
