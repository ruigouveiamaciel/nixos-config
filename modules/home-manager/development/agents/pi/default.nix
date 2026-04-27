{
  lib,
  options,
  pkgs,
  ...
}: {
  config = lib.mkMerge ([
      {
        programs.fish.shellAliases = {
          "pi" = "pnpx @mariozechner/pi-coding-agent@0.70.2";
        };
        home = {
          activation = {
            piPackageActivation = lib.hm.dag.entryAfter ["writeBoundary"] ''
              mkdir -p $HOME/.pi/agent
              ${pkgs.rsync}/bin/rsync -vH --recursive --delete \
                --exclude=node_modules \
                --exclude=sessions \
                --exclude=auth.json \
                --exclude=models.json \
                ${./config}/* $HOME/.pi/agent/
              chmod -R u=rwX,g=,o= $HOME/.pi
            '';
          };
        };
      }
    ]
    ++ (
      lib.optional (options.home ? "persistence")
      {
        home.persistence = {
          "/persist" = {
            directories = [
              ".pi/agent"
            ];
          };
        };
      }
    ));
}
