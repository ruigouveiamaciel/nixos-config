{
  config,
  pkgs,
  ...
}: {
  config = {
    myDarwin = {
      nix.home-manager.enable = true;
      users = {
        enable = true;
        authorized-keys.enable = true;
        users = {
          ruimaciel = {
            authorizedKeys = config.myDarwin.users.authorized-keys.users.rui;
            homeManagerConfigFile = ./home.nix;
            extraSettings = {
              home = "/Users/ruimaciel";
              shell = pkgs.fish;
            };
          };
        };
      };
    };
  };
}
