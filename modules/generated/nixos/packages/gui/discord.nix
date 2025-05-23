{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    (discord.override {
      # nss = nss_latest;
      withOpenASAR = true;
    })
    # discord-ptb
    # discord-canary
    webcord
    # betterdiscord-installer
    #(armcord.override {
    #  nss = nss_latest;
    #})
    legcord

    discordchatexporter-cli
  ];
}
