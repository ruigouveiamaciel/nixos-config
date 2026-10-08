{myModulesPath, ...}: {
  imports = [
    "${myModulesPath}/security/disable-lecture.nix"
    "${myModulesPath}/security/sudo-wheel-only.nix"
    "${myModulesPath}/system/nix-settings.nix"
    "${myModulesPath}/system/nixpkgs.nix"
    "${myModulesPath}/system/no-hibernate.nix"
    "${myModulesPath}/system/immutable-users.nix"
  ];
}
