{myModulesPath, ...}: {
  imports = [
    "${myModulesPath}/development/ai"
    "${myModulesPath}/development/editors/neovim.nix"
    "${myModulesPath}/development/remote/gpg-agent.nix"
    "${myModulesPath}/development/remote/ssh.nix"
    "${myModulesPath}/development/shell/direnv.nix"
    "${myModulesPath}/development/shell/git.nix"
    "${myModulesPath}/development/toolchains"
  ];
}
