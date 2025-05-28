{
  config,
  lib,
  myLib,
  ...
}: let
  cfg = config.myNixOS;

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

  profiles =
    myLib.extendModules
    ({
      name,
      path,
    }: let
      configPath = lib.splitString "." name;
    in {
      inherit path;
      optionsExtension = options: {
        myNixOS.profiles = lib.setAttrByPath configPath (
          options
          // {
            enable = lib.mkEnableOption "enable ${name} bundle";
          }
        );
      };
      configExtension = config: (lib.mkIf (lib.getAttrFromPath (configPath ++ ["enable"]) cfg.profiles) config);
    })
    (myLib.resolveDir ./profiles);
in {
  imports = features ++ profiles;
}
