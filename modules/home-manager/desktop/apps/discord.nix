{
  pkgs,
  lib,
  options,
  ...
}: {
  config = lib.mkMerge ([
      {
        home.packages = with pkgs; [
          vesktop
        ];
      }
    ]
    ++ (lib.optional (options.home ? "persistence") {
      home.persistence = {
        "/persist" = {
          directories = [
            ".config/vesktop"
          ];
        };
      };
    }));
}
