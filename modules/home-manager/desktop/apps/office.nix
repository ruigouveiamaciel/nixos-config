{
  pkgs,
  lib,
  options,
  ...
}: {
  config = lib.mkMerge (
    [
      {
        home.packages = with pkgs; [
          zettlr
          kdePackages.ghostwriter
        ];
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
