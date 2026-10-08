{
  myModulesPath,
  lib,
  options,
  ...
}: {
  imports = [
    "${myModulesPath}/profiles/essentials.nix"
    "${myModulesPath}/profiles/development.nix"
    "${myModulesPath}/shell/starship.nix"
  ];

  config = lib.mkMerge ([
      {
        programs.git = {
          settings = {
            user = {
              email = "5m0k3w0w@proton.me";
              name = "SmOkEwOw";
            };
          };
        };
      }
    ]
    ++ (
      lib.optional (options.home ? "persistence")
      {
        home.persistence = {
          "/persist" = {
            directories = [
              {
                directory = "projects";
                mode = "700";
              }
              {
                directory = "repositories";
                mode = "700";
              }
            ];
          };
        };
      }
    ));
}
