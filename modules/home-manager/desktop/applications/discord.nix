{
  pkgs,
  lib,
  options,
  ...
}: {
  config = lib.mkMerge ([
      {
        home.packages = with pkgs; [
          vesktop
        ];

        wayland.windowManager.hyprland.settings = {
          exec-once = [
            "vesktop"
          ];
        };
      }
    ]
    ++ (lib.optional (builtins.hasAttr "persistence" options.home) {
      home.persistence = {
        "/persist" = {
          directories = [
            ".config/vesktop"
          ];
        };
      };
    }));
}
