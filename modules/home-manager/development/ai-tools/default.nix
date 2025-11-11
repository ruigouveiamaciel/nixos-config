{
  pkgs,
  lib,
  options,
  config,
  ...
}: {
  config = lib.mkMerge ([
      {
        home = {
          packages = [
            pkgs.myOpencode
          ];
          file = {
            "${config.home.homeDirectory}/.config/opencode".source = ./opencode;
          };
        };
      }
    ]
    ++ (
      lib.optional (builtins.hasAttr "persistence" options.home)
      {
        home.persistence = {
          "/persist" = {
            directories = [
              ".cache/opencode"
              ".local/share/opencode"
              ".local/state/opencode"
            ];
          };
        };
      }
    ));
}
