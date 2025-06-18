{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.myNixOS.users.rui;
in {
  options = {
    extraHomeManagerConfigFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "The path for this user's extra home manager config";
    };
  };

  config = {
    myNixOS = {
      nix.home-manager.enable = true;
      shell.fish.enable = true;
      users = {
        enable = true;
        users = {
          rui = {
            authorizedKeys = config.myConstants.users.rui.authorized-keys;
            homeManagerConfigFile = ./home.nix;
            inherit (cfg) extraHomeManagerConfigFile;
            extraGroups = [
              "wheel"
              "video"
              "audio"
              "network"
              "networkmanager"
              "net"
              "docker"
              "podman"
              "git"
              "dialout"
              "plugdev"
            ];
            extraSettings = {
              shell = pkgs.fish;
              password = "123456"; # TODO: Load password from sops
            };
          };
        };
      };
    };
  };
}
