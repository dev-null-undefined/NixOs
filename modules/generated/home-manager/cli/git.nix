{pkgs, ...}: {
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    aliases = {
      graph = "log --decorate --oneline --graph";
      l = "log --color --pretty=format:'%Cred%h%Creset -%C(bold yellow)%d%Creset %s %Cgreen(%cr) %Cblue%an %C(bold blue)<%ae>%Creset %C(dim cyan)%G?' --abbrev-commit --reverse";
      ld = "ld = log -p -1";
    };
    userName = "dev-null-undefined";
    userEmail = "martinkos007@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      core = {
        editor = "nvim";
        autocrlf = "input";
      };
      commit.verbose = true;
      safe.directory = "/etc/nixos";
    };
    lfs = {enable = true;};
    ignores = [".direnv" "result*" ".ccls-cache" "a.out"];
    delta = {enable = true;};
    signing = {
      signByDefault = true;
      key = "47230B659BA8E169";
    };
  };
}
