{
  pkgs,
  config,
  lib,
  ...
}: {
  home = lib.mkMerge [
    {
      packages = [
        (pkgs.prismlauncher.override
          {
            jdks = [
              pkgs.temurin-jre-bin-8
              pkgs.temurin-jre-bin-17
            ];
          })
      ];
    }

    (lib.mkIf (builtins.hasAttr "persistence" config.home) {
      persistence."/persist" = {
        directories = [
          ".local/share/PrismLauncher"
        ];
      };
    })
  ];
}
