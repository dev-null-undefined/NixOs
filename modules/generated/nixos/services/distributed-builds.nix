{
  config,
  self,
  ...
}: {
  sops.secrets."nix-builder-ssh-key" = {
    sopsFile = self.outPath + "/secrets/nix-builder-ssh-key";
    format = "binary";
  };

  programs.ssh.knownHosts.homie.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOZIZhUGVfHjBIlUpj8XqWMokRWJrisOd/aN7PDsYAfo";

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "homie";
        sshUser = "nix-ssh";
        sshKey = config.sops.secrets."nix-builder-ssh-key".path;
        protocol = "ssh-ng";
        systems = ["x86_64-linux" "i686-linux"];
        maxJobs = 12;
        speedFactor = 2;
        supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
      }
    ];
  };
}
