{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkMerge [
    {
      programs.firefox = {
        enable = true;
        package = pkgs.librewolf;
        profiles.smokewow = {
          id = 0;
          isDefault = true;
        };
      };
    }

    (lib.mkIf (builtins.hasAttr "persistence" config.home) {
      home.persistence."/persist" = {
        directories = [
          ".librewolf"
          ".cache/librewolf"
        ];
      };
    })

    (lib.mkIf (builtins.hasAttr "stylix" config) {
      stylix.targets.firefox.profileNames = ["smokewow"];
    })
  ];
}
