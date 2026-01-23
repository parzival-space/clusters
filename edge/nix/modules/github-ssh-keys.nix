{ lib, pkgs, config, ... }:

let
  inherit (lib) mkOption mkIf types mapAttrs';
in
{
  ###### Extend users.users.<name> ######
  options.users.users = mkOption {
    type = types.attrsOf (types.submodule ({ name, ... }: {
      options.githubKeys = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Sync SSH authorized_keys from GitHub for this user.";
        };

        username = mkOption {
          type = types.str;
          description = "GitHub username to fetch SSH keys from.";
        };

        interval = mkOption {
          type = types.str;
          default = "1h";
          description = "How often to sync SSH keys (systemd time format).";
        };
      };
    }));
  };

  ###### Implementation ######
  config =
    let
      usersWithGithubKeys =
        lib.filterAttrs
          (_: u: u.githubKeys.enable or false)
          config.users.users;
    in mkIf (usersWithGithubKeys != {}) {

      systemd.services = mapAttrs'
        (user: u: {
          name = "github-ssh-keys-${user}";
          value = {
            description = "Sync SSH authorized_keys for ${user} from GitHub";
            serviceConfig = {
              Type = "oneshot";
              User = user;
              WorkingDirectory = u.home;
            };
            script = ''
              set -e

              mkdir -p .ssh
              chmod 700 .ssh

              ${pkgs.curl}/bin/curl -fsSL \
                https://github.com/${u.githubKeys.username}.keys \
                | ${pkgs.coreutils}/bin/sort -u \
                > .ssh/authorized_keys

              chmod 600 .ssh/authorized_keys
            '';
          };
        })
        usersWithGithubKeys;

      systemd.timers = mapAttrs'
        (user: u: {
          name = "github-ssh-keys-${user}";
          value = {
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnBootSec = "2min";
              OnUnitActiveSec = u.githubKeys.interval;
              Persistent = true;
            };
          };
        })
        usersWithGithubKeys;
    };
}
