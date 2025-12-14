{
  pkgs,
  lib,
  options,
  ...
}: {
  config = lib.mkMerge (
    [
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
    ]
    ++ (lib.optional (builtins.hasAttr "persistence" options.home) {
      home.persistence."/persist" = {
        directories = [
          ".librewolf"
          ".cache/librewolf"
        ];
      };
    })
    ++ (lib.optional (builtins.hasAttr "stylix" options) {
      stylix.targets.firefox.profileNames = ["smokewow"];
    })
  );
}
