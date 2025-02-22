{
  config,
  lib,
  outputs,
  myLib,
  ...
}: let
  cfg = config.myHomeManager;

  # Taking all modules in ./features and adding enables to them
  features =
    myLib.extendModules
    ({
      name,
      path,
    }: let
      configPath = lib.splitString "." name;
    in {
      inherit path;
      optionsExtension = options: {
        myHomeManager = lib.setAttrByPath configPath (
          options
          // {
            enable = lib.mkEnableOption "enable my ${name} configuration";
          }
        );
      };
      configExtension = config: (lib.mkIf (lib.getAttrFromPath (configPath ++ ["enable"]) cfg) config);
    })
    (myLib.resolveDir ./features);

  # Taking all modules in ./features and adding enables to them
  bundles =
    myLib.extendModules
    ({
      name,
      path,
    }: let
      configPath = lib.splitString "." name;
    in {
      inherit path;
      optionsExtension = options: {
        myHomeManager.bundles = lib.setAttrByPath configPath (
          options
          // {
            enable = lib.mkEnableOption "enable my ${name} configuration";
          }
        );
      };
      configExtension = config: (lib.mkIf (lib.getAttrFromPath (configPath ++ ["enable"]) cfg.bundles) config);
    })
    (myLib.resolveDir ./features);
in {
  imports = features ++ bundles;
}
