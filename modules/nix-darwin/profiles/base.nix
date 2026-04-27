{myModulesPath, ...}: {
  imports = [
    "${myModulesPath}/base/homebrew.nix"
    "${myModulesPath}/base/nix-builders.nix"
    "${myModulesPath}/base/nix-settings.nix"
    "${myModulesPath}/base/nixpkgs.nix"
  ];
}
