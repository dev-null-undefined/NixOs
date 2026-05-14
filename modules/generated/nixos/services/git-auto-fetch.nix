{
  config,
  self,
  pkgs,
  lib,
  ...
}: let
  cfg = config.generated.services.git-auto-fetch;

  serviceName = profile: "git-auto-fetch-${profile}";
  secretName = profile: "git-auto-fetch/${profile}";

  # Top-level mrconfig per profile. Only this thin wrapper lives in the Nix
  # store (and is therefore world-readable); the actual repo list comes from
  # the sops-decrypted include below, which is mode 0400 owned by cfg.user.
  topMrconfig = profile:
    pkgs.writeText "mrconfig-${profile}" ''
      [DEFAULT]
      # FF if the working tree is clean, otherwise just fetch.
      # mr cds into the repo before running this snippet.
      git_update = if [ -z "$(git status --porcelain)" ]; then git pull --ff-only "$@"; else git fetch --all --prune "$@"; fi

      include = cat ${config.sops.secrets.${secretName profile}.path}
    '';

  userHome = config.users.users.${cfg.user}.home;
  userGroup = config.users.users.${cfg.user}.group;

  profileSubmodule = lib.types.submodule ({...}: {
    options = {
      interval = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "1h";
        description = ''
          Systemd OnUnitActiveSec interval between runs. Set to null to disable
          the periodic timer (rely solely on triggers / manual runs).
        '';
      };
      runOnBoot = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Run shortly after boot (OnBootSec=5min).";
      };
      parallelJobs = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Override module-level parallelJobs for this profile.";
      };
      triggers.networkManagerVpnUp = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "wg-cdn77";
        description = ''
          NetworkManager interface name. When a connection with this
          interface-name comes up (action 'up' or 'vpn-up'), the profile's
          fetch service is triggered. Requires networking.networkmanager.enable.
        '';
      };
    };
  });

  vpnTriggerProfiles =
    lib.filterAttrs (_: p: p.triggers.networkManagerVpnUp != null) cfg.profiles;

  nmDispatcherScript = pkgs.writeShellScript "git-auto-fetch-nm-dispatch" ''
    iface="$1"
    action="$2"
    [ "$action" = "up" ] || [ "$action" = "vpn-up" ] || exit 0
    case "$iface" in
    ${lib.concatStringsSep "\n"
      (lib.mapAttrsToList (
          name: p: ''
            ${p.triggers.networkManagerVpnUp})
              ${pkgs.systemd}/bin/systemctl start --no-block ${serviceName name}.service
              ;;''
        )
        vpnTriggerProfiles)}
    esac
  '';
in {
  options = {
    user = lib.mkOption {
      type = lib.types.str;
      default = "martin";
      description = "User account the fetch service runs as. Uses this user's ~/.ssh for git auth.";
    };

    parallelJobs = lib.mkOption {
      type = lib.types.int;
      default = 4;
      description = "Default value for mr's -j flag. Can be overridden per profile.";
    };

    profiles = lib.mkOption {
      type = lib.types.attrsOf profileSubmodule;
      default = {};
      description = ''
        Profile attribute set. Each profile <name> requires a sops-encrypted
        INI file at secrets/git-auto-fetch-<name>, decryptable on this host.

        Profile INI format (mr/myrepos):

          [some-repo]
          checkout = git clone git@github.com:user/some-repo.git $HOME/path/to/some-repo
          fixups = git remote add upstream git@...:upstream/some-repo.git

          [other-repo]
          checkout = git clone git@git.cdn77.eu:org/other.git $HOME/work/other

        Paths in 'checkout' decide where each repo lives (mr runs commands
        from the user's home directory). 'fixups' runs once right after
        checkout and is the place to set up additional remotes.
      '';
      example = lib.literalExpression ''
        {
          personal = {
            interval = "1h";
            runOnBoot = true;
          };
          work = {
            interval = null;
            triggers.networkManagerVpnUp = "wg-cdn77";
          };
        }
      '';
    };
  };

  sops.secrets = lib.mapAttrs' (name: _:
    lib.nameValuePair (secretName name) {
      sopsFile = self.outPath + "/secrets/git-auto-fetch-${name}";
      format = "binary";
      owner = cfg.user;
      group = userGroup;
      mode = "0400";
    })
  cfg.profiles;

  systemd.services = lib.mapAttrs' (name: pCfg:
    lib.nameValuePair (serviceName name) {
      description = "Auto-fetch git repositories (profile: ${name})";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      path = with pkgs; [git openssh coreutils mr bash gnused gnugrep];
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        Group = userGroup;
        WorkingDirectory = userHome;
        Environment = [
          "HOME=${userHome}"
          "USER=${cfg.user}"
        ];
        ExecStart =
          "${pkgs.mr}/bin/mr"
          + " -j${toString (
            if pCfg.parallelJobs != null
            then pCfg.parallelJobs
            else cfg.parallelJobs
          )}"
          + " -c ${topMrconfig name}"
          + " update";
        # mr exits non-zero if any individual repo failed; treat as a soft
        # failure so a single dead remote doesn't fail the whole unit.
        SuccessExitStatus = "0 1";
      };
    })
  cfg.profiles;

  systemd.timers = lib.mapAttrs' (name: pCfg:
    lib.nameValuePair (serviceName name) {
      wantedBy = ["timers.target"];
      timerConfig =
        {Persistent = true;}
        // (lib.optionalAttrs pCfg.runOnBoot {OnBootSec = "5min";})
        // (lib.optionalAttrs (pCfg.interval != null) {OnUnitActiveSec = pCfg.interval;});
    })
  (lib.filterAttrs (_: p: p.interval != null || p.runOnBoot) cfg.profiles);

  networking.networkmanager.dispatcherScripts = lib.mkIf (vpnTriggerProfiles != {} && config.networking.networkmanager.enable) [
    {
      source = nmDispatcherScript;
      type = "basic";
    }
  ];

  assertions = [
    {
      assertion = vpnTriggerProfiles == {} || config.networking.networkmanager.enable;
      message = "generated.services.git-auto-fetch: profiles with triggers.networkManagerVpnUp require networking.networkmanager.enable = true.";
    }
  ];
}
