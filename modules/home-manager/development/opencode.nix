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
          packages = with pkgs; [
            unstable.opencode
          ];

          file."${config.home.homeDirectory}/.config/opencode/INSTRUCTIONS.md".source = ./OPENCODE_INSTRUCTIONS.md;

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
              ".cache/opencode"
              ".local/share/opencode"
              ".local/state/opencode"
            ];
          };
        };
      }
    ));
}
