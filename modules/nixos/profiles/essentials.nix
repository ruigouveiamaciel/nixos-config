{myModulesPath, ...}: {
  imports = [
    ./crucial.nix

    "${myModulesPath}/shell/git.nix"
    "${myModulesPath}/shell/python.nix"
  ];
}
