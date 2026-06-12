{
  pkgs,
  lib,
  options,
  ...
}: {
  config = lib.mkMerge ([
      {
        home.packages = with pkgs; [
          orca-slicer
          openscad
        ];
      }
    ]
    ++ (lib.optional (options.home ? "persistence") {
      home.persistence = {
        "/persist" = {
          directories = [
            {
              directory = ".config/OrcaSlicer";
              mode = "0700";
            }
            {
              directory = ".local/share/orca-slicer";
              mode = "0700";
            }
            {
              directory = ".cache/orca-slicer";
              mode = "0700";
            }
          ];
        };
      };
    }));
}
