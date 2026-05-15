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
            claude-code
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
              ".claude"
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
