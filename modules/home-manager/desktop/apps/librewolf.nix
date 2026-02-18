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
    ++ (lib.optional (options.home ? "persistence") {
      home.persistence."/persist" = {
        directories = [
          ".librewolf"
          ".cache/librewolf"
        ];
      };
    })
    ++ (lib.optional (options ? "stylix") {
      stylix.targets.firefox.profileNames = ["smokewow"];
    })
  );
}
