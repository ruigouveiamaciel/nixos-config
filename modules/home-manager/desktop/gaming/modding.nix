{
  lib,
  options,
  pkgs,
  ...
}: {
  config = lib.mkMerge ([
      {
        home.packages = with pkgs; [
          r2modman
        ];
      }
    ]
    ++ (lib.optional (options.home ? "persistence") {
      home.persistence."/persist" = {
        directories = [
          {
            directory = ".config/r2modman";
            mode = "0700";
          }
          {
            directory = ".config/r2modmanPlus-local";
            mode = "0700";
          }
        ];
      };
    }));
}
