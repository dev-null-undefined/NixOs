{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    (vscode-with-extensions.override
      {
        vscodeExtensions =
          (with vscode-extensions; [
            bbenoist.nix
            vscode-extensions.ms-python.python
            ms-azuretools.vscode-docker
            ms-vscode-remote.remote-ssh
            ms-vscode.cpptools
            esbenp.prettier-vscode
            emmanuelbeziat.vscode-great-icons
            eamodio.gitlens
            mhutchie.git-graph
            ms-vsliveshare.vsliveshare
            jnoortheen.nix-ide
            github.copilot
            ritwickdey.liveserver
          ])
          ++ vscode-utils.extensionsFromVscodeMarketplace [
            {
              name = "avr-support";
              publisher = "rockcat";
              version = "0.0.1";
              sha256 = "sha256-JbO9MZDnd4olODFwoWDHdxsJKIHOb1VhUpAk4g7I1y4=";
            }
            {
              name = "systemverilog";
              publisher = "eirikpre";
              version = "0.13.4";
              sha256 = "sha256-SaBhZv+9gox+lkXUTNWptrOZ74sc95S4AEgrICrSRG0=";
            }
            {
              name = "cpptools-extension-pack";
              publisher = "ms-vscode";
              version = "1.3.0";
              sha256 = "sha256-rHST7CYCVins3fqXC+FYiS5Xgcjmi7QW7M4yFrUR04U=";
            }
            {
              name = "JavaScriptSnippets";
              publisher = "xabikos";
              version = "1.8.0";
              sha256 = "sha256-ht6Wm1X7zien+fjMv864qP+Oz4M6X6f2RXjrThURr6c=";
            }
          ];
      })
  ];
}
