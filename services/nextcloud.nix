{ pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 80 ];
  services.nextcloud = {
    enable = true;
    hostName = "nextcloud";
    https = true;
    caching = {
      apcu = true;
      redis = false;
      memcached = true;
    };
    config = {
      dbtype = "mysql";
      dbname = "nextcloud";
      dbuser = "nextcloud";
      dbhost = "127.0.0.1";
      dbport = 3306;
      dbpass = "MDVkMGU2NDVhYTBlMDQxZTJkMjRjNzRm";
      adminpass = "YjQ3YzBhNTk2MzAwZjgyN2Q0MjY1ZmMz";
    };
  };
}