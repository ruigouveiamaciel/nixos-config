{
  config,
  lib,
  myLib,
  ...
}: let
  cfg = config.myDarwin;

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
in {
  imports = features;
}
