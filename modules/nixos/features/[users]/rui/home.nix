{outputs, ...}: {
  imports = [
    outputs.homeManagerModules.default
    outputs.homeManagerModules.constants
  ];

  myHomeManager = {
    profiles = {
      essentials.enable = true;
      development.enable = true;
    };
  };

  home = {
    username = "rui";
    homeDirectory = "/home/rui";
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}
