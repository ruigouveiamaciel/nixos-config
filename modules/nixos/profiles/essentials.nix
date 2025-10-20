{myModulesPath, ...}: {
  imports = [
    "${myModulesPath}/locales/pt-pt.nix"

    "${myModulesPath}/security/disable-lecture.nix"
    "${myModulesPath}/security/pam-ssh-agent-auth.nix"

    "${myModulesPath}/shell/git.nix"

    "${myModulesPath}/system/nix-ld.nix"
    "${myModulesPath}/system/nix-settings.nix"
    "${myModulesPath}/system/sops.nix"
  ];
}
