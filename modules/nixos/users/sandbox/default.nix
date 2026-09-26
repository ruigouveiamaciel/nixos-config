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
    "${myModulesPath}/system/home-manager.nix"
  ];

  config = lib.mkMerge ([
      {
        users = {
          users.sandbox = {
            uid = 1070;
            group = "users";
            home = "/home/sandbox";
            description = "Sandbox User";
            # openssh.authorizedKeys.keys = config.myConstants.users.smokewow.authorized-keys;
            isNormalUser = true;
            extraGroups =
              filterUnexistentGroups [
              ];
            password = "";
          };
        };
      }
    ]
    ++ (lib.optional (options ? "home-manager") {
      home-manager.users.sandbox.imports = [
        ./home.nix
      ];
    }));
}
