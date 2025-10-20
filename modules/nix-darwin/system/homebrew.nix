{
  lib,
  config,
  ...
}: {
  config = lib.mkMerge [
    {
      homebrew = {
        enable = true;
        onActivation.cleanup = "uninstall";
      };
    }

    (lib.mkIf (builtins.hasAttr "home-manager" config) {
      home-manager = {
        sharedModules = [
          {
            home = {
              sessionPath = [
                "/opt/homebrew/bin"
                "/opt/homebrew/sbin"
              ];
              sessionVariables = {
                XDG_DATA_DIRS = "/opt/homebrew/share:$XDG_DATA_DIRS";
              };
            };
          }
        ];
      };
    })
  ];
}
