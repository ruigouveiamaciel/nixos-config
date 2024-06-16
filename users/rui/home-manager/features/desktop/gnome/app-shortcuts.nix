{pkgs, ...}: let
  echo = "${pkgs.coreutils}/bin/echo";
  grep = "${pkgs.gnugrep}/bin/grep";
  wmctrl = "${pkgs.wmctrl}/bin/wmctrl";
  xprop = "${pkgs.xorg.xprop}/bin/xprop";
  awk = "${pkgs.gawk}/bin/awk";
  wmctrl-switch-script = pkgs.writeShellScriptBin "wmctrl-switch" ''
    # Retrieve list of all windows matching with the provided class
    win_list=$(${wmctrl} -x -l | ${grep} -- "$1" | ${awk} '{print $1}')

    if [ ! -z "$win_list" ]; then
      # Get id of the focused window
      active_win_id=$(${xprop} -root | ${grep} '^_NET_ACTIVE_W' | ${awk} -F'# 0x' '{print $2}')

      # Get window manager class of focused window
      active_win_class=$(${wmctrl} -x -l | ${grep} "$active_win_id" | ${awk} '{print $3}')

      if [ "$1" = "$active_win_class" ]; then
        # Find the next window to focus.
        switch_to=$(${echo} "$win_list" | ${grep} -Pazo "(?<=''${active_win_id}\n)[^\n]*" | ${awk} '{print $1}')

        # If the current window is the last in the list, take the first one.
        if [ -z "$switch_to" ]; then
          switch_to=$(${echo} "$win_list" | ${awk} '{print $1}')
        fi
      else
        switch_to=$(${echo} "$win_list" | ${awk} '{print $1}')
      fi

      # Switch to next window.
      ${wmctrl} -i -a "$switch_to"
    fi
  '';
  wmctrl-switch = "${wmctrl-switch-script}/bin/wmctrl-switch";
in {
  home.packages = [
    pkgs.wmctrl
  ];

  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/vscode-switch-shortcut" = {
      binding = "<Super>n";
      command = "${wmctrl-switch} code.Code";
      name = "Switch to Visual Studio Code";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/vscode-launch-shortcut" = {
      binding = "<Super><Shift>n";
      command = "${pkgs.vscode}/bin/code";
      name = "Launch Visual Studio Code";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/chrome-switch-shortcut" = {
      binding = "<Super>b";
      command = "${wmctrl-switch} google-chrome.Google-chrome";
      name = "Switch to Google Chrome";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/chrome-launch-shortcut" = {
      binding = "<Super><Shift>b";
      command = "${pkgs.google-chrome}/bin/google-chrome-stable";
      name = "Launch to Google Chrome";
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/vscode-switch-shortcut/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/vscode-launch-shortcut/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/chrome-switch-shortcut/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/chrome-launch-shortcut/"
      ];
    };
  };
}
