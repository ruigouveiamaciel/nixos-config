{
  config,
  pkgs,
  inputs,
  ...
}: rec {
  gtk = {
    enable = true;
    font = {
      name = config.fontProfiles.regular.family;
      size = 12;
    };
    theme = {
      name = "Gruvbox-Dark-BL";
      package = pkgs.gruvbox-gtk-theme;
    };
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "volantes_cursors";
      package = pkgs.volantes-cursors;
    };
  };

  dconf.settings = {
    "org/gnome/shell/extensions/user-theme" = {
      name = gtk.theme.name;
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
    "org/gnome/desktop/wm/preferences" = {
      titlebar-font = "${config.fontProfiles.regular.family} 12";
    };
    "org/gnome/desktop/interface" = {
      document-font-name = "${config.fontProfiles.regular.family} 12";
      monospace-font-name = "${config.fontProfiles.monospace.family} 12";
    };
  };

  services.xsettingsd = {
    enable = true;
    settings = {
      "Net/ThemeName" = "${gtk.theme.name}";
      "Net/IconThemeName" = "${gtk.iconTheme.name}";
      "Gtk/CursorThemeName" = "${gtk.cursorTheme.name}";
    };
  };
}
