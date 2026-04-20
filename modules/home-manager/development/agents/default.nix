{
  lib,
  options,
  pkgs,
  inputs,
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
              inputs.peon-ping.packages.${pkgs.stdenv.hostPlatform.system}.default
            ]
            ++ lib.optional (!pkgs.stdenv.isDarwin) lmstudio; # Package is broken in darwin
          sessionVariables = {
            OPENCODE_ENABLE_EXA = "1";
            OPENCODE_DISABLE_CLAUDE_CODE = "1";
            OPENCODE_EXPERIMENTAL_BASH_DEFAULT_TIMEOUT_MS = "720000";
          };
          activation = {
            opencodePackageActivation = lib.hm.dag.entryAfter ["writeBoundary"] ''
              mkdir -p $HOME/.config/opencode
              ${pkgs.rsync}/bin/rsync -vH --recursive --delete --exclude=node_modules ${./opencode}/* $HOME/.config/opencode/
              chmod -R u=rwX,g=,o= $HOME/.config/opencode
            '';
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
