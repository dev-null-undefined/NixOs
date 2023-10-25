{
  self,
  lib,
  pkgs,
  ...
}: let
  users = builtins.map (x: "presentation-" + builtins.toString x) (lib.lists.range 0 20);
  createUser = userName: {
    ${userName} = {
      isNormalUser = true;
      initialPassword = "nixos";
      shell = pkgs.zsh;
      useDefaultShell = false;
    };
  };

  presentation = pkgs.fetchFromGitHub {
    owner = "nix-clan";
    repo = "intro-presentation";
    rev = "6f547024dfa8fd1bc4d0596a3b7791cbadd5e431";
    hash = "sha256-ZpfEWznmgz7F+dyG09oQGq2mwhUqTZgyRSFNBiHPzkw=";
  };

  createHome = user:
    self.lib'.internal.mkHomeNixOsUser user [
      ({lib, ...}: {
        home.activation = {
          presentationFiles = lib.hm.dag.entryAfter ["writeBoundary"] ''
            $DRY_RUN_CMD rm -rf $VERBOSE_ARG ~/presentation
            $DRY_RUN_CMD cp -r $VERBOSE_ARG ${presentation} ~/presentation
            $DRY_RUN_CMD find $VERBOSE_ARG ~/presentation -type d -exec chmod 744 {} \;
            $DRY_RUN_CMD find $VERBOSE_ARG ~/presentation -type f -exec chmod 644 {} \;
          '';
        };
      })
    ];
  createUsers = users: creator: builtins.foldl' (acc: user: acc // user) {} (builtins.map creator users);
in {
  services.openssh.settings.PasswordAuthentication = lib.mkForce true;
  users.users = createUsers users createUser;
  home-manager.users = createUsers users createHome;
}
