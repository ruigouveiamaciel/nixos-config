{
  config,
  pkgs,
  myModulesPath,
  lib,
  ...
}: {
  imports = [
    "${myModulesPath}/shell/fish.nix"
    "${myModulesPath}/system/home-manager.nix"
  ];

  config = lib.mkMerge [
    {
      users.users.ruimaciel = {
        openssh.authorizedKeys.keys = config.myConstants.users.rui.authorized-keys;
        home = "/Users/ruimaciel";
        shell = pkgs.fish;
      };

      system.primaryUser = "ruimaciel";
    }

    (lib.mkIf (builtins.hasAttr "home-manager" config) {
      home-manager.users.ruimaciel = {
        imports = [
          ./home.nix
        ];
      };
    })
  ];
}
