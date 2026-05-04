{
  options,
  lib,
  myHomeManagerModulesPath,
  pkgs,
  ...
}: {
  config = lib.mkMerge (
    [
      {
        programs.fish = {
          enable = true;
          package = pkgs.unstable.fish;
          vendor = {
            completions.enable = true;
            config.enable = true;
            functions.enable = true;
          };
        };
      }
    ]
    ++ (lib.optional (options ? "home-manager") {
      home-manager.sharedModules = [
        "${myHomeManagerModulesPath}/shell/fish.nix"
      ];
    })
  );
}
