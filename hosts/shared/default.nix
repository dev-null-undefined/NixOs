{
  custom.wireguard.allConfigs = [
    {
      name = "RPI-home_assistant-brnikov";
      publicKey = "IYujtBpTlBBZ2hzv6P6BDQqm9hOAizitkPN4YvnOpxE=";
      ip = "10.100.0.2/24";
    }
    {
      name = "RPI-home_assistant-domov";
      publicKey = "ynYjI3o4szvHwuZU89njBTHs9lMsSRxn5iEeqI+d7BY=";
      ip = "10.100.0.4/24";
    }
    {
      name = "idk-laptop";
      publicKey = "aHMZOnJ2ZKQE+Hycwc7nlHrtfRAqw2Vuuij8xxQOY0s=";
      ip = "10.100.0.3/24";
      #forwardAll = true;
    }
    {
      name = "oracle-server";
      publicKey = "8JrfiB+8IBk4RxA4DR+hFnrOACwVylUjW3pIRch5UTg=";
      ip = "10.100.0.1/24";
      forwardAll = true;
      isServer = true;
      endpoint = "130.61.112.64";
    }
  ];
}
