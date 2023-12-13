{pkgs, ...}: let
  src = pkgs.fetchFromGitHub {
    owner = "drduh";
    repo = "YubiKey-Guide";
    rev = "f2e5ef2c18ee1003460941dfcfa3d6f66f9ce0a2";
    hash = "sha256-AicuOR/VTr3WYFQnHrqyLcLQ6gWEE16hi+Ln50jBTWw=";
  };
  guide = "${src}/README.md";
  view-yubikey-guide = pkgs.writeShellScriptBin "view-yubikey-guide" ''
    viewer="$(type -P xdg-open || true)"
    if [ -z "$viewer" ]; then
      viewer="${pkgs.glow}/bin/glow -p"
    fi
    exec $viewer "${guide}"
  '';
  shortcut = pkgs.makeDesktopItem {
    name = "yubikey-guide";
    icon = "${pkgs.yubikey-manager-qt}/share/ykman-gui/icons/ykman.png";
    desktopName = "drduh's YubiKey Guide";
    genericName = "Guide to using YubiKey for GPG and SSH";
    comment = "Open the guide in a reader program";
    categories = ["Documentation"];
    exec = "${view-yubikey-guide}/bin/view-yubikey-guide";
  };
  yubikey-guide = pkgs.symlinkJoin {
    name = "yubikey-guide";
    paths = [view-yubikey-guide shortcut];
  };
in {
  environment.systemPackages = [yubikey-guide];
  home-manager.users.martin.home.file."YubiKey-Guide".source = src;
}
