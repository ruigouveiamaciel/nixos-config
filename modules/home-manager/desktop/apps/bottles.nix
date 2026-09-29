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
            (unstable.bottles.override
              {
                removeWarningPopup = true;
              })
          ];
        };
      }
    ]
    ++ (lib.optional (options.home ? "persistence") {
      home.persistence."/persist" = {
        directories = [
          {
            directory = ".local/share/bottles";
            mode = "0700";
          }
        ];
      };
    })
  );
}
