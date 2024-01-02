let
  wallpaper = builtins.fetchurl {
    url = "https://images-assets.nasa.gov/image/EC02-0131-9/EC02-0131-9~orig.jpg";
    sha256 = "cef181c3f62a35d2d640c070fcd3c4325b70774a5743802207ef1647cd30ae72";
    name = "wallpaper.jpg";
  };
in {
  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-uri = "file://${wallpaper}";
      picture-uri-dark = "file://${wallpaper}";
    };
    "org/gnome/desktop/screensaver" = {
      picture-uri = "file://${wallpaper}";
    };
  };
}