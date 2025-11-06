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
            # (pkgs.writeShellScriptBin "opencode" ''
            #   exec ${lib.getExe' pkgs.nodejs_24 "npx"} -y opencode-ai "$@"
            # '')
            # (pkgs.writeShellScriptBin "claude" ''
            #   exec ${lib.getExe' pkgs.nodejs_24 "npx"} -y claude "$@"
            # '')
          ];
          file = {
            "${config.home.homeDirectory}/.config/opencode/INSTRUCTIONS.md".source = ./OPENCODE_INSTRUCTIONS.md;
            "${config.home.homeDirectory}/.config/opencode/opencode.json".source = ./opencode.json;
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
