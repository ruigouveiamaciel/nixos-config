{
  lib,
  options,
  config,
  pkgs,
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
      lib.optional (options.home ? "persistence")
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
