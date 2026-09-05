{
  config,
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
        boot.postBootCommands = ''
          mkdir -p /home/smokewow
          chown 1069:users /home/smokewow
          chmod 750 /home/smokewow
        '';

        users = {
          users.smokewow = {
            uid = 1069;
            description = "SmOkEwOw";
            openssh.authorizedKeys.keys = config.myConstants.users.smokewow.authorized-keys;
            isNormalUser = true;
            extraGroups = filterUnexistentGroups [
              "wheel"
              "audio"
              "video"
              "render"
              "docker"
              "podman"
              "dialout"
              "plugdev"
            ];
            shell = config.programs.fish.package;
            hashedPassword = "";
          };
        };
      }
    ]
    ++ (lib.optional (options ? "home-manager") {
      home-manager.users.smokewow.imports = [
        ./home.nix
      ];
    }));
}
