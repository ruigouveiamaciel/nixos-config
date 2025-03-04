{outputs, ...}: {
  imports = [outputs.homeManagerModules.default];

  myHomeManager = {
    bundles = {
      core.enable = true;
      development.enable = true;
    };
  };

  home = {
    username = "ruimaciel";
    homeDirectory = "/Users/ruimaciel";
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}
