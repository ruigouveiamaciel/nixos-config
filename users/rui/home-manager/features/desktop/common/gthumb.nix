{
  pkgs,
  config,
  ...
}: let
  inherit (config.colorscheme) colors;
in {
  home.packages = with pkgs; [
    gthumb
  ];

  xdg.mimeApps.defaultApplications = {
    "image/jpeg" = ["org.gnome.gThumb.desktop"];
    "image/png" = ["org.gnome.gThumb.desktop"];
    "image/gif" = ["org.gnome.gThumb.desktop"];
    "image/webp" = ["org.gnome.gThumb.desktop"];
    "image/svg+xml" = ["org.gnome.gThumb.desktop"];
  };
}
