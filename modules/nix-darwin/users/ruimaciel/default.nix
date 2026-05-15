{
  config,
  myModulesPath,
  lib,
  options,
  ...
}: {
  imports = [
    "${myModulesPath}/shell/fish.nix"
    "${myModulesPath}/system/home-manager.nix"
  ];

  config = lib.mkMerge ([
      {
        users.users.ruimaciel = {
          openssh.authorizedKeys.keys = config.myConstants.users.rui.authorized-keys;
          home = "/Users/ruimaciel";
          shell = config.programs.fish.package;
        };

        system.primaryUser = "ruimaciel";
      }
    ]
    ++ (lib.optional (options ? "home-manager") {
      home-manager.users.ruimaciel = {
        imports = [
          ./home.nix
        ];
      };
    }));
}
