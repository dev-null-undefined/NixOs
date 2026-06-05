final: prev: {
  adi1090x-plymouth = prev.callPackage ./adi1090x-plymouth {};
  material-symbols = prev.callPackage ./material-symbols {};
  prometheus-qbittorrent-exporter = prev.callPackage ./prometheus-qbittorrent-exporter {};
  slack-mcp-server = prev.callPackage ./slack-mcp-server {};
  thunderbird-mcp = prev.callPackage ./thunderbird-mcp {};

  home-assistant-electrolux-status = let
    pyPkgs = prev.home-assistant.python3Packages;
    pyelectroluxocp = pyPkgs.callPackage ./pyelectroluxocp {};
  in
    prev.callPackage ./home-assistant-electrolux-status {
      inherit pyelectroluxocp;
      inherit (pyPkgs) aiofiles;
    };
}
