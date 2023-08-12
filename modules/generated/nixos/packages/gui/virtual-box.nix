{
  virtualisation = {
    virtualbox = {
      guest = {
        enable = true;
        x11 = true;
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
