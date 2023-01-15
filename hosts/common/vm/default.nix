{
  lib,
  config,
  modulesPath,
  ...
}: {
  isVM = true;
  imports = [(modulesPath + "/virtualisation/qemu-vm.nix")];
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
}
