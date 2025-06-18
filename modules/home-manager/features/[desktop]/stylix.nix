{
  inputs,
  pkgs,
  config,
  ...
}: {
  imports = [
    inputs.stylix.homeModules.stylix
  ];

  config = {
    # home.pointerCursor.gtk.enable = true;
    #
    # wayland.windowManager.hyprland.settings.exec-once = [
    #   "hyprctl setcursor ${config.stylix.cursor.name} ${builtins.toString config.stylix.cursor.size}"
    # ];

    stylix = {
      enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
      polarity = "dark";

      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
      };

      fonts = {
        sizes = {
          applications = 12;
          desktop = 12;
          popups = 12;
          terminal = 12;
        };

        serif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Serif";
        };

        sansSerif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Sans";
        };

        monospace = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Sans Mono";
        };

        emoji = {
          package = pkgs.noto-fonts-emoji;
          name = "Noto Color Emoji";
        };
      };
    };
  };
}
