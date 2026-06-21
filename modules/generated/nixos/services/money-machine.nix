{self, ...}: {
  services.money-machine = {
    enable = true;
    secretsFile = self.outPath + "/secrets/money-machine.env";
  };
}
