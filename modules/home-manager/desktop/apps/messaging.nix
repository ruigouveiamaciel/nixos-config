{
  pkgs,
  lib,
  options,
  ...
}: {
  config = lib.mkMerge ([
      {
        home.packages = with pkgs; [
          # vesktop
          signal-desktop
        ];
      }
    ]
    ++ (lib.optional (options.home ? "persistence") {
      home.persistence = {
        "/persist" = {
          directories = [
            {
              directory = ".config/Signal";
              mode = "0700";
            }
            {
              directory = ".config/vesktop";
              mode = "0700";
            }
          ];
        };
      };
    }));
}
