{
  lib,
  options,
  pkgs,
  ...
}: {
  config = lib.mkMerge ([
      rec {
        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          settings = {
            jupiter = {
              host = "10.0.0.42";
              forwardAgent = true;
            };
            saturn = {
              host = "10.0.50.42";
              forwardAgent = true;
            };
            forgejo = {
              host = "ssh-git.iuseneovim.fyi";
              proxyCommand = "${lib.getExe' pkgs.cloudflared "cloudflared"} access ssh --hostname %h";
            };
          };
        };

        programs.fish.shellAbbrs = {
          "jupiter" = "kitty +kitten ssh smokewow@${programs.ssh.settings.jupiter.host}";
          "unlock-jupiter" = "ssh root@${programs.ssh.settings.jupiter.host} -p 2222";
          "saturn" = "kitty +kitten ssh smokewow@${programs.ssh.settings.saturn.host}";
          "unlock-saturn" = "ssh root@${programs.ssh.settings.saturn.host} -p 2222";
        };
      }
    ]
    ++ (lib.optional (options.home ? "persistence") {
      home.persistence = {
        "/persist" = {
          directories = [
            {
              directory = ".ssh";
              mode = "0700";
            }
          ];
        };
      };
    }));
}
