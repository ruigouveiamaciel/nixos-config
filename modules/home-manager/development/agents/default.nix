{
  pkgs,
  lib,
  options,
  ...
}: {
  config = lib.mkMerge ([
      {
        home.packages = with pkgs.unstable; [
          pi-coding-agent
          qemu
        ];
      }
    ]
    ++ (lib.optional (options.home ? "persistence") {
      home.persistence = {
        "/persist" = {
          directories = [
            {
              directory = ".pi";
              mode = "0700";
            }
          ];
        };
      };
    }));
}
