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
    stateVersion = "24.11";
  };
}
