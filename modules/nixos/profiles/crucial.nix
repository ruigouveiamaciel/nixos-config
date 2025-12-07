{myModulesPath, ...}: {
  imports = [
    "${myModulesPath}/locales/pt-pt.nix"
    "${myModulesPath}/security/disable-lecture.nix"
    "${myModulesPath}/system/nix-settings.nix"
    "${myModulesPath}/system/nixpkgs.nix"
  ];
}
