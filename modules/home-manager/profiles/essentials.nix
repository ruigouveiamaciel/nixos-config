{myModulesPath, ...}: {
  imports = [
    ./crucial.nix

    "${myModulesPath}/shell/gpg.nix"
    "${myModulesPath}/shell/utilities"
  ];
}
