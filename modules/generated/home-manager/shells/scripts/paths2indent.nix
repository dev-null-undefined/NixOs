{pkgs, ...}: let
  tools = pkgs.fetchFromGitHub {
    owner = "bAndie91";
    repo = "tools";
    rev = "cb767e3c1be21173e279b707e0c8cf9e0eaecd17";
    hash = "sha256-yaqZJ607uiyHB/JpkQrdgKgRIZXA65wUGmw82/IMEYU=";
  };
in {
  home.file."user-tools/paths2indent" = {
    executable = true;
    source = tools + "/user-tools/paths2indent";
  };
}
