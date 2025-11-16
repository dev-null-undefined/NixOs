{
  programs.atuin = {
    enable = true;
    flags = ["--disable-up-arrow"];
    settings = {
      sync_frequency = "1m";
      sync_address = "https://atuin.dev-null.me";
    };
  };
}
