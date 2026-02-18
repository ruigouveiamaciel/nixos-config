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
    ++ (lib.optional (options.home ? "persistence") {
      home.persistence."/persist" = {
        directories = [
          ".steam"
          ".local/share/Steam"
          ".factorio"
        ];
      };
    }));
}
