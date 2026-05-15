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
        users = {
          users.rui = {
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
            ];
            shell = config.programs.fish.package;
            hashedPassword = "";
          };
        };
      }
    ]
    ++ (lib.optional (options ? "home-manager") {
      home-manager.users.rui.imports = [
        ./home.nix
      ];
    }));
}
