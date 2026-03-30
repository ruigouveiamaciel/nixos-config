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
          packages = with pkgs.unstable;
            [
              opencode
              claude-code
            ]
            ++ lib.optional (!pkgs.stdenv.isDarwin) lmstudio; # Package is broken in darwin
          sessionVariables = {
            OPENCODE_ENABLE_EXA = "1";
          };
          file = {
            "${config.home.homeDirectory}/.config/opencode/opencode.json".source = ./opencode/opencode.json;
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
              ".claude"
              ".lmstudio"
            ];
            files = [
              {
                file = ".claude.json";
                method = "symlink";
              }
            ];
          };
        };
      }
    ));
}
