{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    guake
  ];

  home.file.".config/autostart/guake.desktop".text = ''
    [Desktop Entry]
    Name=Guake Terminal
    TryExec=${pkgs.guake}/bin/guake
    Exec=${pkgs.guake}/bin/guake
    Type=Application
    StartupNotify=false
    X-Desktop-File-Install-Version=0.22
  '';

  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/guake" = {
      binding = "F1";
      command = "${pkgs.guake}/bin/guake-toggle";
      name = "Toggle Guake";
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = ["/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/guake/"];
    };

    "apps/guake/general" = {
      compat-delete = "delete-sequence";
      display-n = 0;
      display-tab-names = 0;
      gtk-use-system-default-theme = true;
      hide-tabs-if-one-tab = false;
      history-size = 2000;
      load-guake-yml = true;
      max-tab-name-length = 100;
      mouse-display = true;
      open-tab-cwd = true;
      prompt-on-close-tab = 1;
      prompt-on-quit = false;
      quick-open-command-line = "code -g %(file_path)s:%(line_number)s";
      quick-open-enable = true;
      quick-open-in-current-terminal = false;
      restore-tabs-notify = true;
      restore-tabs-startup = true;
      save-tabs-when-changed = true;
      schema-version = "3.9.0";
      scroll-keystroke = true;
      start-at-login = false;
      use-default-font = false;
      use-popup = true;
      use-scrollbar = true;
      use-trayicon = false;
      window-halignment = 0;
      window-height = 50;
      window-losefocus = false;
      window-refocus = false;
      window-tabbar = true;
      window-width = 100;
    };

    "apps/guake/keybindings/global" = {
      show-hide = "disabled";
    };

    "apps/guake/keybindings/local" = {
      close-tab = "<Alt>w";
      close-terminal = "disabled";
      decrease-transparency = "disabled";
      focus-terminal-down = "<Alt>Down";
      focus-terminal-left = "<Alt>Left";
      focus-terminal-right = "<Alt>Right";
      focus-terminal-up = "<Alt>Up";
      increase-transparency = "disabled";
      move-tab-left = "disabled";
      move-tab-right = "disabled";
      new-tab = "<Alt>t";
      new-tab-home = "<Alt>h";
      next-tab = "disabled";
      next-tab-alt = "disabled";
      open-link-under-terminal-cursor = "<Alt>o";
      previous-tab = "disabled";
      previous-tab-alt = "disabled";
      quit = "<Alt>q";
      rename-current-tab = "<Alt>r";
      search-on-web = "<Alt>l";
      search-terminal = "<Primary>f";
      split-tab-horizontal = "disabled";
      split-tab-vertical = "disabled";
      switch-tab-last = "disabled";
      switch-tab1 = "<Alt>1";
      switch-tab10 = "<Alt>0";
      switch-tab2 = "<Alt>2";
      switch-tab3 = "<Alt>3";
      switch-tab4 = "<Alt>4";
      switch-tab5 = "<Alt>5";
      switch-tab6 = "<Alt>6";
      switch-tab7 = "<Alt>7";
      switch-tab8 = "<Alt>8";
      switch-tab9 = "<Alt>9";
      toggle-fullscreen = "<Alt>f";
      toggle-hide-on-lose-focus = "disabled";
      zoom-in = "<Primary>plus";
      zoom-in-alt = "disabled";
      zoom-out = "<Primary>minus";
    };

    "guake/style" = {
      cursor-blink-mode = 1;
      cursor-shape = 1;
    };

    "apps/guake/style/background" = {
      transparency = 100;
    };

    "apps/guake/style/font" = {
      allow-bold = true;
      palette = "#282828282828:#CCCC24241D1D:#989897971A19:#D7D799992120:#454585858888:#B1B162618685:#68689D9D6A6A:#EBEBDBDBB2B2:#3C3C38383636:#FBFB49493434:#B8B8BBBB2626:#FAFABDBC2F2F:#8383A5A59898:#D3D386869B9B:#8E8EC0C07C7B:#FBFBF1F1C7C7:#EBEBDBDBB2B2:#282828282828";
      palette-name = "Gruvbox Dark";
      style = "${config.fontProfiles.monospace.family} 12";
    };
  };
}
