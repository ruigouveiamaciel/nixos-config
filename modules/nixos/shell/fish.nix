{
  options,
  lib,
  myHomeManagerModulesPath,
  ...
}: {
  config = lib.mkMerge (
    [
      {
        programs.fish = {
          enable = true;
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
