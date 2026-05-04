{
  config,
  myModulesPath,
  ...
}: {
  imports = [
    "${myModulesPath}/profiles/essentials.nix"
    "${myModulesPath}/profiles/development.nix"
    "${myModulesPath}/shell/starship.nix"
  ];

  home = {
    username = "ruimaciel";
    homeDirectory = "/Users/ruimaciel";

    sessionVariables = {
      SHELL = "${config.programs.fish.package}/bin/fish";
    };

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.11";
  };
}
