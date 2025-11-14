{myModulesPath, ...}: {
  imports = [
    "${myModulesPath}/base/nixpkgs.nix"
    "${myModulesPath}/base/command-not-found.nix"
  ];
}
