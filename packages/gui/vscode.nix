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
    jnoortheen.nix-ide
    github.copilot
  ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "veriloghdl";
      publisher = "mshr-h";
      version = "1.5.5";
      sha256 = "sha256-zWe69azXBEK6pzEt2L3Lv5Y2d99J4s1tmswmVMhyNG4=";
    }
    {
      name = "verilogformat";
      publisher = "ericsonj";
      version = "1.0.1";
      sha256 = "sha256-TqsKN2NRzICWGf0ydUHlTg/F5iNrlZqt4sh17UGsxPU=";
    }
    {
      name = "avr-support";
      publisher = "rockcat";
      version = "0.0.1";
      sha256 = "sha256-JbO9MZDnd4olODFwoWDHdxsJKIHOb1VhUpAk4g7I1y4=";
    }
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
  vscode-with-extensions = pkgs.master.vscode-with-extensions.override {
    vscodeExtensions = extensions;
  };
in { config.environment.systemPackages = [ vscode-with-extensions ]; }
