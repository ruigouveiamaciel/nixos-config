{
  config,
  lib,
  myLib,
  ...
}: let
  cfg = config.myDarwin;

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
        myDarwin = lib.setAttrByPath configPath (
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
        myDarwin.bundles = lib.setAttrByPath configPath (
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
