{
  inputs,
  pkgs,
  ...
}: let
  greek_islands = pkgs.fetchurl {
    url = "https://images-assets.nasa.gov/image/iss070e035893/iss070e035893~orig.jpg";
    hash = "sha256-rw6zPH2EJg3qCZ7mKUCPad6CkNkcXTMjD2OL0qMmkW8=";
  };
  pico_island = pkgs.fetchurl {
    url = "https://images-assets.nasa.gov/image/iss036e009390/iss036e009390~orig.jpg";
    hash = "";
  };
in {
  imports = [
    inputs.stylix.homeModules.stylix
  ];

  config = {
    stylix = {
      enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
      #image = greek_islands;
      polarity = "dark";

      fonts = {
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
