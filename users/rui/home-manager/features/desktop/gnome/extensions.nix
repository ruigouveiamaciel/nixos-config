{pkgs, ...}: {
  home.packages = with pkgs; [
    gnomeExtensions.dash-to-panel
    gnomeExtensions.notification-timeout
    gnomeExtensions.user-themes
    gnomeExtensions.appindicator
    gnomeExtensions.x11-gestures
  ];

  dconf.settings = {
    "org/gnome/shell" = {
      # Enabled extensions
      enabled-extensions = [
        "dash-to-panel@jderose9.github.com"
        "appindicatorsupport@rgcjonas.gmail.com"
        "notification-timeout@chlumskyvaclav.gmail.com"
        "x11gestures@joseexposito.github.io"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
      ];
    };

    # Extension - Notification Timeout
    "org/gnome/shell/extensions/notification-timeout" = {
      always-normal = true;
      ignore-idle = true;
      timeout = 2500;
    };

    # Extension - Dash to Panel settings
    "org/gnome/shell/extensions/dash-to-panel" = {
      app-ctrl-hotkey-1 = [""];
      app-ctrl-hotkey-10 = [""];
      app-ctrl-hotkey-2 = [""];
      app-ctrl-hotkey-3 = [""];
      app-ctrl-hotkey-4 = [""];
      app-ctrl-hotkey-5 = [""];
      app-ctrl-hotkey-6 = [""];
      app-ctrl-hotkey-7 = [""];
      app-ctrl-hotkey-8 = [""];
      app-ctrl-hotkey-9 = [""];
      app-ctrl-hotkey-kp-1 = [""];
      app-ctrl-hotkey-kp-10 = [""];
      app-ctrl-hotkey-kp-2 = [""];
      app-ctrl-hotkey-kp-3 = [""];
      app-ctrl-hotkey-kp-4 = [""];
      app-ctrl-hotkey-kp-5 = [""];
      app-ctrl-hotkey-kp-6 = [""];
      app-ctrl-hotkey-kp-7 = [""];
      app-ctrl-hotkey-kp-8 = [""];
      app-ctrl-hotkey-kp-9 = [""];
      app-hotkey-1 = [""];
      app-hotkey-10 = [""];
      app-hotkey-2 = [""];
      app-hotkey-3 = [""];
      app-hotkey-4 = [""];
      app-hotkey-5 = [""];
      app-hotkey-6 = [""];
      app-hotkey-7 = [""];
      app-hotkey-8 = [""];
      app-hotkey-9 = [""];
      app-hotkey-kp-1 = [""];
      app-hotkey-kp-10 = [""];
      app-hotkey-kp-2 = [""];
      app-hotkey-kp-3 = [""];
      app-hotkey-kp-4 = [""];
      app-hotkey-kp-5 = [""];
      app-hotkey-kp-6 = [""];
      app-hotkey-kp-7 = [""];
      app-hotkey-kp-8 = [""];
      app-hotkey-kp-9 = [""];
      app-shift-hotkey-1 = [""];
      app-shift-hotkey-10 = [""];
      app-shift-hotkey-2 = [""];
      app-shift-hotkey-3 = [""];
      app-shift-hotkey-4 = [""];
      app-shift-hotkey-5 = [""];
      app-shift-hotkey-6 = [""];
      app-shift-hotkey-7 = [""];
      app-shift-hotkey-8 = [""];
      app-shift-hotkey-9 = [""];
      app-shift-hotkey-kp-1 = [""];
      app-shift-hotkey-kp-10 = [""];
      app-shift-hotkey-kp-2 = [""];
      app-shift-hotkey-kp-3 = [""];
      app-shift-hotkey-kp-4 = [""];
      app-shift-hotkey-kp-5 = [""];
      app-shift-hotkey-kp-6 = [""];
      app-shift-hotkey-kp-7 = [""];
      app-shift-hotkey-kp-8 = [""];
      app-shift-hotkey-kp-9 = [""];
      appicon-margin = 8;
      appicon-padding = 4;
      available-monitors = [0];
      click-action = "CYCLE";
      dot-position = "BOTTOM";
      hot-keys = true;
      hotkey-prefix-text = "SuperAlt";
      hotkeys-overlay-combo = "TEMPORARILY";
      intellihide = true;
      intellihide-key-toggle = [];
      intellihide-key-toggle-text = "";
      intellihide-pressure-threshold = 128;
      intellihide-use-pressure = true;
      intellihide-animation-time = 100;
      intellihide-close-delay = 200;
      isolate-monitors = false;
      isolate-workspaces = true;
      leftbox-padding = -1;
      panel-anchors = ''
        {
          "0":"MIDDLE",
          "1":"MIDDLE",
          "2":"MIDDLE"
        }
      '';
      panel-element-positions-monitors-sync = true;
      panel-element-positions = ''
        {
          "0":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}],
          "1":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}],
          "2":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}]
        }
      '';
      panel-lengths = ''
        {
          "0":100,
          "1":100,
          "2":100
        }
      '';
      panel-positions = ''
        {
          "0":"TOP",
          "1":"TOP",
          "2":"TOP"
        }
      '';
      panel-sizes = ''
        {
          "0":48,
          "1":48,
          "2":48
        }
      '';
      primary-monitor = 0;
      scroll-icon-action = "NOTHING";
      scroll-panel-action = "NOTHING";
      status-icon-padding = -1;
      tray-padding = -1;
      window-preview-title-position = "TOP";
    };

    # Extension - X11 Gestures
    "org/gnome/shell/extensions/x11gestures" = {
      swipe-fingers = 3;
    };
  };
}
