{
  lib,
  options,
  ...
}: {
  config = lib.mkMerge (
    [
      {
        programs.steam.enable = true;
      }
    ]
    ++ (lib.optional (options ? "home-manager") {
      home-manager.sharedModules = [
        ({options, ...}: {
          config = lib.mkMerge (lib.optional (options.home ? "persistence") {
            home.persistence."/persist" = {
              directories = [
                {
                  directory = ".steam";
                  mode = "0700";
                }
                {
                  directory = ".local/share/Steam";
                  mode = "0700";
                }
                {
                  directory = ".factorio";
                  mode = "0700";
                }
              ];
            };
          });
        })
      ];
    })
  );
}
