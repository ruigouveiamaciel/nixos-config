{myModulesPath, ...}: {
  imports = [
    "${myModulesPath}/development/editors/neovim.nix"
    "${myModulesPath}/development/shell/git.nix"
    "${myModulesPath}/development/shell/tmux.nix"
    "${myModulesPath}/development/toolchains"
  ];
}
