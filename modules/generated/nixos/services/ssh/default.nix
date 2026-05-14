{
  lib,
  config,
  ...
}: {
  services.openssh = {
    enable = true;
    ports = [22 8022];
    settings = {
      PasswordAuthentication = lib.mkDefault false;
      X11Forwarding = true;
    };
  };

  users.users = {
    root.openssh.authorizedKeys.keys = config.registry.values.sshKeys;
  };
}
