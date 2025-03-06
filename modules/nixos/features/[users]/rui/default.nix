{
  config,
  pkgs,
  ...
}: {
  config = {
    myNixOS = {
      nix.home-manager.enable = true;
      users = {
        enable = true;
        authorized-keys.enable = true;
        users = {
          rui = {
            authorizedKeys = config.myNixOS.users.authorized-keys.users.rui;
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
