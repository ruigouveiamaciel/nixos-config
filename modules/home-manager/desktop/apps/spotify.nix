{
  pkgs,
  lib,
  options,
  ...
}: {
  home = lib.mkMerge (
    [
      {
        packages = with pkgs; [
          spotify
        ];
      }
    ]
    ++ (lib.optional (options.home ? "persistence") {
      persistence."/persist" = {
        directories = [
          ".config/spotify"
        ];
      };
    })
  );
}
