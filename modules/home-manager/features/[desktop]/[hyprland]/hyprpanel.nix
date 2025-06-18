{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.hyprpanel.homeManagerModules.hyprpanel
  ];

  config = {
    home.packages = with pkgs; [libnotify];

    programs.hyprpanel = {
      enable = true;
      hyprland.enable = true;
      overwrite.enable = true;
      settings = {
        wallpaper.enable = false;
        bar = {
          volume.label = false;
          bluetooth.label = false;
        };
        theme = {
          name = "catppuccin_macchiato_vivid";
          font = {
            size = "1rem";
            inherit (config.stylix.fonts.sansSerif) name;
          };
        };
        menus = {
          clock = {
            weather.enabled = false;
          };
        };
        layout = {
          "bar.layouts" = let
            layout = {
              left = ["power" "workspaces"];
              middle = ["clock"];
              right = ["systray" "volume" "bluetooth" "notifications"];
            };
          in {
            "0" = layout;
            "1" = layout;
          };
        };
      };
    };
  };
}
