{
  lib,
  options,
  ...
}: {
  config = lib.mkMerge ([
      {
        wayland.windowManager.hyprland.settings = {
          general = {
            allow_tearing = true;
          };
          misc = {
            vrr = 2;
          };
          exec-once = [
            "steam"
          ];
        };
      }
    ]
    ++ (lib.optional (builtins.hasAttr "persistence" options.home) {
      home.persistence."/persist" = {
        directories = [
          ".steam"
          ".local/share/Steam"
          ".factorio"
        ];
      };
    }));
}
