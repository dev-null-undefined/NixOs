{pkgs, ...}: {
  home.packages = with pkgs; [
    (symlinkJoin
      {
        name = "wlogout";
        paths = [wlogout];
        buildInputs = [makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/wlogout --add-flags "-p layer-shell -b 2"
        '';
      })
  ];

  home.file.".config/wlogout" = {
    source = ./config;
    recursive = true;
  };
}
