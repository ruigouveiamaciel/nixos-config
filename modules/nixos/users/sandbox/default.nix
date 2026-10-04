{
  myModulesPath,
  lib,
  options,
  ...
}: {
  imports = [
    "${myModulesPath}/system/home-manager.nix"
  ];

  config = lib.mkMerge ([
      {
        users = {
          users.smokewow = {
            uid = 1069;
            group = "users";
            home = "/home/smokewow";
            description = "SmOkEwOw";
            isNormalUser = true;
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
