{
  config,
  pkgs,
  ...
}: {
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
            };
          };
        };
      };
    };
  };
}
