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
        home = {
          username = "rui";
          homeDirectory = "/home/rui";

          # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
          stateVersion = "24.11";
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
            ];
          };
        };
      }
    ));
}
