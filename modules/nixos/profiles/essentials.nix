{myModulesPath, ...}: {
  imports = [
    ./crucial.nix

    "${myModulesPath}/shell/git.nix"
    "${myModulesPath}/system/nix-ld.nix"
  ];
}
