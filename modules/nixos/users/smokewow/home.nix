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
      {}
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
