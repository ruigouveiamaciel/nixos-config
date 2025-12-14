{
  lib,
  options,
  ...
}: {
  config = lib.mkMerge ([
      {
        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          matchBlocks = {
            jupiter = {
              host = "10.0.0.42";
              forwardAgent = true;
            };
            saturn = {
              host = "10.0.50.42";
              forwardAgent = true;
            };
          };
        };
      }
    ]
    ++ (lib.optional (options.home ? "persistence") {
      home.persistence = {
        "/persist" = {
          files = [
            ".ssh/known_hosts"
          ];
        };
      };
    }));
}
