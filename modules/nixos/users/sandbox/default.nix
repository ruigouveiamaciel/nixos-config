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
          users.sandbox = {
            uid = 1069;
            group = "users";
            home = "/home/sandbox";
            description = "Sandbox User";
            isNormalUser = true;
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
