{pkgs, ...}: let
  extensions =
    (with pkgs.vscode-extensions; [
      bbenoist.nix
      ms-python.python
      ms-azuretools.vscode-docker
      ms-vscode-remote.remote-ssh
      ms-vscode.cpptools
      coenraads.bracket-pair-colorizer-2
      esbenp.prettier-vscode
      emmanuelbeziat.vscode-great-icons
      eamodio.gitlens
      mhutchie.git-graph
      ms-vsliveshare.vsliveshare
      jnoortheen.nix-ide
      github.copilot
      ritwickdey.liveserver
    ])
    ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "avr-support";
        publisher = "rockcat";
        version = "0.0.1";
        sha256 = "sha256-JbO9MZDnd4olODFwoWDHdxsJKIHOb1VhUpAk4g7I1y4=";
      }
      {
        name = "JavaScriptSnippets";
        publisher = "xabikos";
        version = "1.8.0";
        sha256 = "sha256-ht6Wm1X7zien+fjMv864qP+Oz4M6X6f2RXjrThURr6c=";
      }
    ];
  vscode-with-extensions =
    pkgs.vscode-with-extensions.override {vscodeExtensions = extensions;};
in {config.environment.systemPackages = [vscode-with-extensions];}
