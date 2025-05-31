{
  outputs,
  pkgs,
  ...
}: {
  imports = [
    outputs.homeManagerModules.default
    outputs.homeManagerModules.constants
  ];

  myHomeManager = {
    profiles = {
      essentials.enable = true;
      development.enable = true;
    };
    shell = {
      mpv.enable = true;
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
      SHELL = "${pkgs.fish}/bin/fish";
      XDG_DATA_DIRS = "/opt/homebrew/share:$XDG_DATA_DIRS";
    };

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.11";
  };
}
