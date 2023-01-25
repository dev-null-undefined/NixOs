{
  lib,
  config,
  modulesPath,
  ...
}: {
  options.isVM = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Whether the current system is VM";
  };

  config = lib.mkIf (config.isVM) {
    virtualisation = {
      memorySize = 4 * 1024;

      cores = 4;

      forwardPorts = [
        {
          host.port = 9022;
          guest.port = 22;
        }
      ];
    };
    users.users.martin.initialPassword = "1234";
  };
}
