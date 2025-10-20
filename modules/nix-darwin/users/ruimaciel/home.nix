{
  pkgs,
  myModulesPath,
  ...
}: {
  imports = [
    "${myModulesPath}/profiles/minimal.nix"
    "${myModulesPath}/profiles/shell.nix"
    "${myModulesPath}/profiles/development.nix"
  ];

  home = {
    username = "ruimaciel";
    homeDirectory = "/Users/ruimaciel";

    sessionVariables = {
      SHELL = "${pkgs.fish}/bin/fish";
    };

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.11";
  };
}
