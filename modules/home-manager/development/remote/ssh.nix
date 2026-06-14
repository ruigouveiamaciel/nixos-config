{
  lib,
  options,
  pkgs,
  ...
}: {
  config = lib.mkMerge ([
      {
        # services.ssh-agent = {
        #   enable = true;
        # };

        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          settings = {
            # "*" = {
            #   IdentitiesOnly = "yes";
            #   IdentityAgent = "none";
            # };
            jupiter = {
              header = "Match Host 10.0.0.42";
              forwardAgent = true;
            };
            saturn = {
              header = "Match Host 10.0.50.42";
              forwardAgent = true;
            };
            forgejo = {
              header = "Match Host ssh-git.iuseneovim.fyi";
              proxyCommand = "${lib.getExe' pkgs.cloudflared "cloudflared"} access ssh --hostname %h";
            };
          };
        };

        programs.fish.shellAbbrs = {
          "jupiter" = "kitty +kitten ssh smokewow@10.0.0.42";
          "unlock-jupiter" = "ssh root@10.0.0.42 -p 2222";
          "saturn" = "kitty +kitten ssh smokewow@10.0.50.42";
          "unlock-saturn" = "ssh root@10.0.50.42 -p 2222";
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
