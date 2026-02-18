{
  lib,
  options,
  config,
  inputs,
  pkgs,
  ...
}: {
  config = lib.mkMerge ([
      {
        home = {
          packages = [
            inputs.opencode.packages."${pkgs.stdenv.hostPlatform.system}".opencode
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
