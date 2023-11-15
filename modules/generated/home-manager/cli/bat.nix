{pkgs, ...}: {
  programs.bat = {
    enable = true;
    config = {
      theme = "Monokai Extended";
      style = "grid,numbers,changes";
    };
    extraPackages = with pkgs.bat-extras; [batman batpipe batgrep batdiff batwatch prettybat];
  };
}
