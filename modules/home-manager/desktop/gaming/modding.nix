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
          deadlock-mod-manager
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
          {
            directory = ".local/share/dev.stormix.deadlock-mod-manager";
            mode = "0700";
          }
          {
            directory = ".cache/dev.stormix.deadlock-mod-manager";
            mode = "0700";
          }
        ];
      };
    }));
}
