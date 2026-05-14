{
  registry = {
    domain = "dev-null.me";
    tailnetDomain = "rat-python.ts.net";

    hosts = {
      homie = {
        lanIp = "192.168.2.1";
        wgIp = "10.100.0.4";
        tailscaleIp = "100.103.242.75";
      };
      homie-vpn = {
        lanIp = "10.200.200.2";
      };
      oracle-server = {
        wgIp = "10.100.0.1";
        tailscaleIp = "100.105.178.96";
      };
      brnikov = {
        wgIp = "10.100.0.2";
        tailscaleIp = "100.69.94.56";
      };
      prosek-wagner = {
        tailscaleIp = "100.107.165.74";
      };
      honey = {
        tailscaleIp = "100.83.239.55";
      };
      idk = {
        wgIp = "10.100.0.3";
      };
      xps = {
        wgIp = "10.100.0.5";
        tailscaleIp = "100.84.21.87";
      };
      x1 = {
        tailscaleIp = "100.111.56.12";
      };
    };
  };
}
