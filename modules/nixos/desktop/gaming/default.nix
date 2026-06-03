{
  myHomeManagerModulesPath,
  lib,
  options,
  ...
}: {
  imports = [./steam.nix ./thrustmaster.nix];

  config = lib.mkMerge (lib.optional (options ? "home-manager") {
    home-manager.sharedModules = [
      "${myHomeManagerModulesPath}/desktop/gaming"
    ];
  });
}
