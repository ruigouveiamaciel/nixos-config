{myModulesPath, ...}: {
  imports = [
    "${myModulesPath}/system/home-manager.nix"
    "${myModulesPath}/system/homebrew.nix"
    "${myModulesPath}/system/nix-settings.nix"
  ];
}
