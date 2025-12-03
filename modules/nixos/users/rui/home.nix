{myModulesPath, ...}: {
  imports = [
    "${myModulesPath}/profiles/base.nix"
    "${myModulesPath}/profiles/shell.nix"
    "${myModulesPath}/profiles/development.nix"
  ];

  home = {
    username = "rui";
    homeDirectory = "/home/rui";

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.11";
  };
}
