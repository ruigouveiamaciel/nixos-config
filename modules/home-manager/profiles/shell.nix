{myModulesPath, ...}: {
  imports = [
    "${myModulesPath}/shell/fish.nix"
    "${myModulesPath}/shell/gpg.nix"
    "${myModulesPath}/shell/starship.nix"
    "${myModulesPath}/shell/utilities"
  ];
}
