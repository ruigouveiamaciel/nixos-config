{pkgs, ...}: {
  config = {
    wayland.windowManager.hyprland.settings = {
      windowrule = [
        "noanim, class:^(flameshot)$"
        "float, class:^(flameshot)$"
        "move -760 0, class:^(flameshot)$"
        "pin, class:^(flameshot)$"
        "monitor 1, class:^(flameshot)$"
      ];
      bind = [
        ", Print, exec, flameshot screen"
        "CTRL, Print, exec, flameshot gui"
      ];
    };

    services.flameshot = {
      enable = true;
      package = pkgs.flameshot.override {
        enableWlrSupport = true;
      };
      settings = {
        General = {
          copyURLAfterUpload = false;
          saveAfterCopy = true;
          showDesktopNotification = false;
          showHelp = false;
          showStartupLaunchMessage = false;
          useJpgForClipboard = true;
          saveAsFileExtension = "png";
          savePathFixed = true;
        };
      };
    };
  };
}
