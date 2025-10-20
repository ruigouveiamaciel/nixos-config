{myModulesPath, ...}: {
  imports = [
    "${myModulesPath}/shell/fish.nix"
    "${myModulesPath}/shell/git.nix"
    "${myModulesPath}/shell/gpg.nix"
    "${myModulesPath}/shell/mpv.nix"
    "${myModulesPath}/shell/ssh.nix"
    "${myModulesPath}/shell/starship.nix"
    "${myModulesPath}/shell/utilities.nix"
  ];
}
