{
  config,
  pkgs,
  myModulesPath,
  lib,
  options,
  ...
}: let
  filterUnexistentGroups = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  imports = [
    "${myModulesPath}/shell/fish.nix"
    "${myModulesPath}/system/home-manager.nix"
  ];

  config = lib.mkMerge ([
      {
        users = {
          users.rui = {
            description = "Rui";
            openssh.authorizedKeys.keys = config.myConstants.users.rui.authorized-keys;
            isNormalUser = true;
            extraGroups = filterUnexistentGroups [
              "wheel"
              "video"
              "audio"
              "network"
              "networkmanager"
              "net"
              "docker"
              "podman"
              "dialout"
              "plugdev"
            ];
            shell = pkgs.fish;
            hashedPassword = "";
          };
        };
      }
    ]
    ++ (lib.optional (options ? "home-manager") {
      home-manager.users.rui = {
        imports = [
          ./home.nix
        ];
      };
    }));
}
