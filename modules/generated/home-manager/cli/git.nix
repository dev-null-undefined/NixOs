{pkgs, ...}: {
  programs.git = {
    enable = true;
    settings = {
      alias = {
        graph = "log --decorate --oneline --graph";
        l = "log --color --pretty=format:'%Cred%h%Creset -%C(bold yellow)%d%Creset %s %Cgreen(%cr) %Cblue%an %C(bold blue)<%ae>%Creset %C(dim cyan)%G?' --abbrev-commit --reverse";
        ld = "ld = log -p -1";
      };
      user = {
        name = "dev-null-undefined";
        email = "martinkos007@gmail.com";
      };
      init.defaultBranch = "main";
      core = {
        editor = "nvim";
        autocrlf = "input";
      };
      push = {autoSetupRemote = true;};
      commit.verbose = true;
      safe.directory = "/etc/nixos";
    };
    includes = [
      {
        condition = "gitdir:~/Work/CDN77/";
        #path = "~/.config/git/config-work";
        contents = {
          user.name = "Martin Kos";
        };
      }
    ];
    lfs = {enable = true;};
    ignores = [".direnv" "result*" ".ccls-cache" "a.out" ".idea"];
    signing = {
      signByDefault = true;
      key = "B1C4FAB94F0F1443";
    };
  };
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
