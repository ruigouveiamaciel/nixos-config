{
  config,
  pkgs,
  myModulesPath,
  lib,
  options,
  ...
}: {
  imports = [
    "${myModulesPath}/shell/fish.nix"
    "${myModulesPath}/base/home-manager.nix"
  ];

  config = lib.mkMerge ([
      {
        users.users.ruimaciel = {
          openssh.authorizedKeys.keys = config.myConstants.users.rui.authorized-keys;
          home = "/Users/ruimaciel";
          shell = pkgs.fish;
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
