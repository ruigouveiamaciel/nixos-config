{
  pkgs,
  options,
  lib,
  ...
}: {
  home = lib.mkMerge (
    [
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
    ]
    ++ (lib.optional (builtins.hasAttr "persistence" options.home) {
      persistence."/persist" = {
        directories = [
          ".local/share/PrismLauncher"
        ];
      };
    })
  );
}
