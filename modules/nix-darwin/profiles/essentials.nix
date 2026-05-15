{myModulesPath, ...}: {
  imports = [
    "${myModulesPath}/system/homebrew.nix"
    "${myModulesPath}/system/nix-builders.nix"
    "${myModulesPath}/system/nix-settings.nix"
    "${myModulesPath}/system/nixpkgs.nix"
  ];
}
