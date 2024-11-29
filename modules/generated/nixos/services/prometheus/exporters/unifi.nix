{
  services.prometheus.exporters.unpoller = {
    enable = true;
    controllers = [
      {
        user = "prometheus";
        pass = "/var/unifi-prometheus-pass";
        url = "https://127.0.0.1:8443";
        verify_ssl = false;
      }
    ];
  };
}
