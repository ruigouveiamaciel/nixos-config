{myModulesPath, ...}: {
  imports = [
    "${myModulesPath}/development/direnv.nix"
    "${myModulesPath}/development/neovim.nix"
    "${myModulesPath}/development/nix.nix"
    "${myModulesPath}/development/sdks.nix"
    "${myModulesPath}/development/sops.nix"
    "${myModulesPath}/development/opencode.nix"
  ];
}
