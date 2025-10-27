{
  pkgs,
  lib,
  options,
  ...
}: {
  config = lib.mkMerge ([
      {
        home = {
          packages = with pkgs; [
            unstable.opencode
          ];

          sessionVariables = {
            OPENCODE_CONFIG = ./opencode.json;
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
              ".config/opencode"
              ".cache/opencode"
              ".local/share/opencode"
              ".local/state/opencode"
            ];
          };
        };
      }
    ));
}
