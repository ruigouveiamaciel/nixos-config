{myModulesPath, ...}: {
  imports = [
    ./crucial.nix

    "${myModulesPath}/shell/utilities"
  ];
}
