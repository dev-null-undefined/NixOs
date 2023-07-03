{modulesPath, ...}: {
  imports = [(modulesPath + "/virtualisation/qemu-vm.nix")];

  isVM = true;

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
}
