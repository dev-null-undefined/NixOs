{
  virtualisation = {
    virtualbox = {
      guest = {
        enable = true;
      };
      host = {
        enable = true;
        enableHardening = false;
        enableExtensionPack = true;
      };
    };
  };
  users.extraGroups.vboxusers.members = ["martin"];
}
