{myModulesPath, ...}: {
  imports = [
    ./crucial.nix

    "${myModulesPath}/shell/git.nix"
  ];
}
