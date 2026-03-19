{
  config,
  self,
  ...
}: {
  sops.secrets."nix-builder-ssh-key" = {
    sopsFile = self.outPath + "/secrets/nix-builder-ssh-key";
    format = "binary";
  };

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "homie";
        sshUser = "nix-ssh";
        sshKey = config.sops.secrets."nix-builder-ssh-key".path;
        protocol = "ssh-ng";
        system = "x86_64-linux";
        maxJobs = 8;
        speedFactor = 2;
        supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
      }
    ];
  };
}
