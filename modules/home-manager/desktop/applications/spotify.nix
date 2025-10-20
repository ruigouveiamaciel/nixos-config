{
  pkgs,
  lib,
  config,
  ...
}: {
  home = lib.mkMerge [
    {
      packages = with pkgs; [
        spotify
      ];
    }

    (lib.mkIf (builtins.hasAttr "persistence" config.home) {
      persistence."/persist" = {
        directories = [
          ".config/spotify"
        ];
      };
    })
  ];
}
