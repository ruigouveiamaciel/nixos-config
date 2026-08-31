{
  lib,
  options,
  pkgs,
  ...
}: {
  imports = [
    # ./claude
    # ./pi
  ];

  config = lib.mkMerge ([
      {
        home = {
          packages = with pkgs.unstable; [
            # mcp-nixos
            # mcporter
            lmstudio
          ];
        };
      }
    ]
    ++ (
      lib.optional (options.home ? "persistence")
      {
        home.persistence = {
          "/persist" = {
            directories = [
              ".mcporter"
              ".lmstudio"
            ];
          };
        };
      }
    ));
}
