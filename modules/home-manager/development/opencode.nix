{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkMerge [
    {
      home.packages = with pkgs; [
        unstable.opencode
      ];

      wayland.windowManager.hyprland.settings = {
        exec-once = [
          "vesktop"
        ];
      };
    }

    (lib.mkIf (builtins.hasAttr "persistence" config.home) {
      home.persistence = {
        "/persist" = {
          directories = [
            ".local/share/opencode"
          ];
        };
      };
    })
  ];
}
