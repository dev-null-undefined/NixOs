{
  networking.networkmanager.ensureProfiles.profiles."gsm-o2-cz" = {
    connection = {
      id = "O2-CZ";
      type = "gsm";
      autoconnect = true;
      autoconnect-retries = 0;
    };
    gsm = {
      apn = "internet";
      pin = "$GSM_O2_CZ_PIN";
      home-only = true;
    };
    ipv4.method = "auto";
    ipv6 = {
      addr-gen-mode = "stable-privacy";
      method = "auto";
      may-fail = true;
    };
  };
}
