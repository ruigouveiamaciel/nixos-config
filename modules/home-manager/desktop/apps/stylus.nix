{
  pkgs,
  lib,
  options,
  ...
}: {
  config = lib.mkMerge (
    [
      {
        home = {
          packages = with pkgs; [
            xournalpp
            rnote
            krita
          ];
        };
      }
    ]
    ++ (lib.optional (options.home ? "persistence") {
      home.persistence."/persist" = {
        directories = [
          {
            directory = ".config/xournalpp";
            mode = "0700";
          }
          {
            directory = ".cache/krita";
            mode = "0700";
          }
          {
            directory = ".locak/share/krita";
            mode = "0700";
          }
        ];
        files = [
          {
            file = ".config/kritadisplayrc";
            parentDirectory = {
              mode = "0700";
            };
          }
          {
            file = ".config/kritarc";
            parentDirectory = {
              mode = "0700";
            };
          }
        ];
      };
    })
  );
}
