{
  pkgs,
  lib,
  config,
  ...
}: {
  home = lib.mkMerge [
    {
      packages = with pkgs; [
        vesktop
      ];
    }

    (lib.mkIf (builtins.hasAttr "persistence" config.home) {
      persistence = {
        "/persist" = {
          directories = [
            ".config/vesktop"
          ];
        };
      };
    })
  ];
}
