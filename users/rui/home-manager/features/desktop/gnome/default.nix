{
  pkgs,
  lib,
  config,
  ...
}:
with lib.hm.gvariant; {
  imports = [
    ../common
    ./extensions.nix
    ./guake.nix
    ./wallpaper.nix
    ./app-shortcuts.nix
  ];

  home.packages = with pkgs; [
    xclip
  ];

  xdg.mimeApps.defaultApplications = {
    "inode/directory" = ["org.gnome.Nautilus.desktop"];
  };

  dconf.settings = {
    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      disable-while-typing = false;
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/shell/app-switcher" = {
      current-workspace-only = true;
    };

    "org/gnome/mutter" = {
      attach-modal-dialogs = true;
      center-new-windows = true;
      dynamic-workspaces = true;
      edge-tiling = true;
    };

    "org/gnome/desktop/search-providers" = {
      disable-external = false;
      disabled = ["org.gnome.Nautilus.desktop"];
    };

    "org/gnome/desktop/interface" = {
      enable-hot-corners = false;
      gtk-enable-primary-paste = false;
      show-battery-percentage = true;
    };

    "org/gnome/desktop/screensaver" = {
      lock-delay = mkUint32 3600;
      lock-enabled = false;
    };

    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 0;
    };

    "org/gnome/desktop/notifications" = {
      show-in-lock-screen = true;
    };

    "org/gnome/desktop/privacy" = {
      remember-recent-files = false;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "interactive";
      sleep-inactive-ac-type = "nothing";
    };

    "org/gnome/shell" = {
      last-selected-power-profile = "performance";
      favorite-apps = [];
    };

    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
    };

    # Keyboard Shortcuts
    "org/gnome/desktop/wm/keybindings" = {
      activate-window-menu = [];
      begin-move = [];
      begin-resize = [];
      cycle-group = [];
      cycle-group-backward = [];
      cycle-panels = [];
      cycle-panels-backward = [];
      cycle-windows = [];
      cycle-windows-backward = [];
      maximize = [];
      minimize = [];
      move-to-monitor-down = [];
      move-to-monitor-left = [];
      move-to-monitor-right = [];
      move-to-monitor-up = [];
      move-to-workspace-1 = [];
      move-to-workspace-last = [];
      move-to-workspace-left = ["<Shift><Super>Left"];
      move-to-workspace-right = ["<Shift><Super>Right"];
      switch-applications = [];
      switch-applications-backward = [];
      switch-group = [];
      switch-group-backward = [];
      switch-panels = [];
      switch-panels-backward = [];
      switch-to-workspace-1 = [];
      switch-to-workspace-last = [];
      switch-to-workspace-left = ["<Super>Left"];
      switch-to-workspace-right = ["<Super>Right"];
      toggle-maximized = ["<Alt>Return"];
      switch-windows = ["<Alt>Tab"];
      switch-windows-backward = ["<Shift><Alt>Tab"];
      unmaximize = [];
      show-desktop = ["<Super>d"];
    };

    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left = [];
      toggle-tiled-right = [];
    };

    "org/gnome/mutter/wayland/keybindings" = {
      restore-shortcuts = [];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      help = [];
      home = ["<Super>e"];
      logout = [];
      magnifier = [];
      magnifier-zoom-in = [];
      magnifier-zoom-out = [];
      screenreader = [];
      search = ["<Alt>space"];
    };

    "org/gnome/shell/keybindings" = {
      focus-active-notification = [];
      screenshot = ["Print"];
      show-screenshot-ui = ["<Control>Print"];
      toggle-message-tray = [];
      toggle-quick-settings = [];
      toggle-application-view = ["<Super>a"];
    };
  };
}
