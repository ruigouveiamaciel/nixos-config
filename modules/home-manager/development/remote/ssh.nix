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
