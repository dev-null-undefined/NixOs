{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    (master.discord.override {
      # nss = nss_latest;
      withOpenASAR = true;
    })
    # discord-ptb
    # discord-canary
    webcord
    # betterdiscord-installer
    #(master.armcord.override {
    #  nss = nss_latest;
    #})
    master.armcord

    discordchatexporter-cli
  ];
}
