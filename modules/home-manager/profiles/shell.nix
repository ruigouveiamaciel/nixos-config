{myModulesPath, ...}: {
  imports = [
    "${myModulesPath}/shell/gpg.nix"
    "${myModulesPath}/shell/starship.nix"
    "${myModulesPath}/shell/utilities"
  ];
}
