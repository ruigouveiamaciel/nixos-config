{outputs, ...}: {
  imports = [outputs.homeManagerModules.default];

  home = {
    username = "rui";
    homeDirectory = "/home/rui";
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}
