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
    ++ (lib.optional (builtins.hasAttr "persistence" options.home) {
      persistence."/persist" = {
        directories = [
          ".config/spotify"
        ];
      };
    })
  );
}
