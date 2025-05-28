{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.myDarwin.users.rui;
in {
  options = {
    extraHomeManagerConfigFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "The path for this user's extra home manager config";
    };
  };

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
            inherit (cfg) extraHomeManagerConfigFile;
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
