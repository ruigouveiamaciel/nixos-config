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

    sessionPath = [
      "/opt/homebrew/bin"
      "/opt/homebrew/sbin"
    ];
    sessionVariables = {
      XDG_DATA_DIRS = "/opt/homebrew/share:$XDG_DATA_DIRS";
    };

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.11";
  };
}
