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
          # {
          #   directory = "";
          #   mode = "0700";
          # }
        ];
      };
    })
  );
}
