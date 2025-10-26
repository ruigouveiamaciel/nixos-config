{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkMerge [
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

    (lib.mkIf (builtins.hasAttr "persistence" config.home) {
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
    })
  ];
}
