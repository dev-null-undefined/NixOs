{ pkgs, ... }:

let
  extensions = (with pkgs.vscode-extensions; [
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
    ms-vscode.cpptools
  ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "LiveServer";
      publisher = "ritwickdey";
      version = "5.6.1";
      sha256 =
        "40f31932db5857e7507d64e7880ee7928ee45ee92a53d83a5a3e580d87cbea1c";
    }
    {
      name = "JavaScriptSnippets";
      publisher = "xabikos";
      version = "1.8.0";
      sha256 =
        "86de969b55fbce27a7f9f8ccbfceb8a8ff8ecf833a5fa7f64578eb4e1511afa7";
    }
  ];
  vscode-with-extensions =
    pkgs.vscode-with-extensions.override { vscodeExtensions = extensions; };
in { config.environment.systemPackages = [ vscode-with-extensions ]; }
