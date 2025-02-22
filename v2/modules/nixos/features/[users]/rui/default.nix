_: {
  config = {
    myNixOS = {
      nix.home-manager.enable = true;
      users = {
        enable = true;
        users = {
          rui = {
            authorizedKeys = [
              builtins.readFile
              ./authorized-keys/cardno_18_657_927.pub
            ];
            homeManagerConfigFile = ./home.nix;
            extraSettings = {
              password = "12345678";
            };
          };
        };
      };
    };
  };
}
