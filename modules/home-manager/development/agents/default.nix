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

              mcp-nixos
            ]
            ++ lib.optional (!pkgs.stdenv.isDarwin) lmstudio; # Package is broken in darwin
          sessionVariables = {
            OPENCODE_ENABLE_EXA = "1";
            OPENCODE_DISABLE_CLAUDE_CODE = "1";
            OPENCODE_EXPERIMENTAL_BASH_DEFAULT_TIMEOUT_MS = "720000";
          };
          file = {
            "${config.home.homeDirectory}/.config/opencode/opencode.json".source = ./opencode.json;
            "${config.home.homeDirectory}/.config/opencode/skills/caveman/SKILL.md".source = ./skills/caveman-reasoning/SKILL.md;
            "${config.home.homeDirectory}/.config/opencode/skills/caveman-commit/SKILL.md".source = ./skills/caveman-commit/SKILL.md;
            "${config.home.homeDirectory}/.config/opencode/skills/caveman-compress".source = ./skills/caveman-compress;
            "${config.home.homeDirectory}/.config/opencode/skills/caveman-review/SKILL.md".source = ./skills/caveman-review/SKILL.md;
            "${config.home.homeDirectory}/.config/opencode/skills/mymrflow/SKILL.md".source = ./skills/mymrflow/SKILL.md;
            "${config.home.homeDirectory}/.config/opencode/skills/mymrflow-check-pipeline/SKILL.md".source = ./skills/mymrflow-check-pipeline/SKILL.md;
            "${config.home.homeDirectory}/.config/opencode/skills/mymrflow-generate-changeset/SKILL.md".source = ./skills/mymrflow-generate-changeset/SKILL.md;
            "${config.home.homeDirectory}/.config/opencode/skills/mymrflow-generate-description/SKILL.md".source = ./skills/mymrflow-generate-description/SKILL.md;
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
