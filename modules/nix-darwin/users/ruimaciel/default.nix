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
    "${myModulesPath}/system/home-manager.nix"
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
    ++ (lib.optional (builtins.hasAttr "home-manager" options) {
      home-manager.users.ruimaciel = {
        imports = [
          ./home.nix
        ];
      };
    }));
}
