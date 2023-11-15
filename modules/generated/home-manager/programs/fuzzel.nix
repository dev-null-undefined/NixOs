{pkgs, ...}: {
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "${pkgs.kitty}/bin/kitty";
        layer = "overlay";
        icon-theme = "Papirus-Dark";
        prompt = ''"❯  "'';
        show-actions = "yes";
        lines = "20";
        width = 50;
      };
      colors = {
        background = "282a36fa";
        selection = "3d4474fa";
        border = "fffffffa";
      };
    };
  };
}
