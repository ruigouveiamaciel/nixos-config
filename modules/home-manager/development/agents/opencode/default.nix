{
  lib,
  options,
  pkgs,
  ...
}: {
  config = lib.mkMerge ([
      {
        home = {
          packages = with pkgs.unstable; [
            opencode
          ];
          sessionVariables = {
            OPENCODE_ENABLE_EXA = "1";
            OPENCODE_DISABLE_CLAUDE_CODE = "1";
            OPENCODE_EXPERIMENTAL_BASH_DEFAULT_TIMEOUT_MS = "720000";
          };
          activation = {
            opencodePackageActivation = lib.hm.dag.entryAfter ["writeBoundary"] ''
              mkdir -p $HOME/.config/opencode
              ${pkgs.rsync}/bin/rsync -vH --recursive --delete --exclude=node_modules ${./config}/* $HOME/.config/opencode/
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
            ];
          };
        };
      }
    ));
}
