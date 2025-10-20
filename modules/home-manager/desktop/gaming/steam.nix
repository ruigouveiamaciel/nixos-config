{
  lib,
  config,
  ...
}: {
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

  home = lib.mkIf (builtins.hasAttr "persistence" config.home) {
    persistence."/persist" = {
      directories = [
        ".steam"
        ".local/share/Steam"
        ".factorio"
      ];
    };
  };
}
