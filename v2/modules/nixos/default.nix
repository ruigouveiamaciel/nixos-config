{
  config,
  lib,
  outputs,
  myLib,
  ...
} @ args: let
  cfg = config.myNixOS;

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
        myNixOS = lib.setAttrByPath configPath (
          options
          // {
            enable = lib.mkEnableOption "enable my ${name} configuration";
          }
        );
      };
      configExtension = config: (lib.mkIf (lib.getAttrFromPath (configPath ++ ["enable"]) cfg) config);
    })
    (myLib.resolveDir ./features);

  # Taking all modules in ./bundles and adding enables to them
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
        myNixOS.bundles = lib.setAttrByPath configPath (
          options
          // {
            enable = lib.mkEnableOption "enable ${name} bundle";
          }
        );
      };
      configExtension = config: (lib.mkIf (lib.getAttrFromPath (configPath ++ ["enable"]) cfg.bundles) config);
    })
    (myLib.resolveDir ./bundles);
in {
  imports = features ++ bundles;
}
