{ pkgs, ... }:

let
  extensions = (with pkgs.vscode-extensions; [
    #  bbenoist.Nix
    #  ms-python.python
      ms-azuretools.vscode-docker
      ms-vscode-remote.remote-ssh
      ms-vscode.cpptools 
    #  CoenraadS.bracket-pair-colorizer
      esbenp.prettier-vscode
      emmanuelbeziat.vscode-great-icons
    ]); #++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
  #}];
  vscode-with-extensions = pkgs.vscode-with-extensions.override {
      vscodeExtensions = extensions;
  };
in {
  config.environment.systemPackages = [
      vscode-with-extensions
  ];
}
