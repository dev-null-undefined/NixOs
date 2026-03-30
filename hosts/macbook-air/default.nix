{self, ...}: {
  # Generated modules
  generated = {
    homebrew.all.enable = true;
    system.enable = true;
  };

  # User
  home-manager.users = self.lib'.internal.mkHomeDarwinUser "martin.kos" [];

  system.primaryUser = "martin.kos";
  system.stateVersion = 6;
}
