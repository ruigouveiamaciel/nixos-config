{
  options,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkMerge (
    [
      {
        programs.ssh = {
          startAgent = true;
          enableAskPassword = true;
          extraConfig = ''
            Match Host 10.0.0.42
              ForwardAgent yes

            Match Host 10.0.50.42
              ForwardAgent yes

            Match Host ssh-git.iuseneovim.fyi
              ProxyCommand ${lib.getExe' pkgs.cloudflared "cloudflared"} access ssh --hostname %h
          '';
        };
      }
    ]
    ++ (lib.optional (options ? "home-manager") {
      home-manager.sharedModules = [
        ({
          options,
          config,
          lib,
          ...
        }: {
          config =
            lib.mkMerge
            ([
                {
                  programs.fish.shellAbbrs = let
                    kitten = lib.optionalString (config.programs.kitty.enable or false) "kitty +kitten ";
                  in {
                    "jupiter" = "${kitten}ssh smokewow@10.0.0.42";
                    "unlock-jupiter" = "ssh root@10.0.0.42 -p 2222";
                    "saturn" = "${kitten}ssh smokewow@10.0.50.42";
                    "unlock-saturn" = "ssh root@10.0.50.42 -p 2222";
                  };
                }
              ]
              ++ (
                lib.optional (options.home ? "persistence") {
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
                }
              ));
        })
      ];
    })
  );
}
