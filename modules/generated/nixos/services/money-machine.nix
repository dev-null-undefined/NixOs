{self, ...}: {
  services.money-machine = {
    enable = true;
    user = "martin";
    secretsFile = self.outPath + "/secrets/money-machine.env";
  };
}
