{config, ...}: {
  services.filebeat = {
    enable = true;
    inputs.nginx = {
      type = "log";
      paths = ["/var/log/nginx/access.log"];
      fields_under_root = true;
      json = {
        keys_under_root = true;
        add_error_key = true;
      };
      fields = {
        service = {
          type = "nginx";
          inherit (config.services.nginx.package) version name;
        };
      };
    };
  };
}
