{
  pkgs,
  config,
  ...
}: let
  screenshotFull = pkgs.writeShellScript "flameshot-full-screenshot" ''
    ${pkgs.flameshot}/bin/flameshot full -c
    # Play shutter sound after the screenshot was taken (no visual feedback otherwise)
    ${pkgs.pulseaudio}/bin/paplay ${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/camera-shutter.oga > /dev/null 2>&1 &
  '';
in {
  home.packages = with pkgs; [
    grim
  ];

  services.flameshot = {
    enable = true;
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
        savePath = "${config.home.homeDirectory}/Screenshots";
        # Wayland support
        useGrimAdapter = true;
        disabledGrimWarning = true;
      };
    };
  };

  xdg.desktopEntries = {
    "net.local.flameshot" = {
      type = "Application";
      name = "Take screenshot (select area)";
      exec = "${pkgs.flameshot}/bin/flameshot gui";
      noDisplay = true;
      startupNotify = false;
      settings."X-KDE-GlobalAccel-CommandShortcut" = "true";
    };
    "net.local.flameshot-full" = {
      type = "Application";
      name = "Take screenshot of whole screen";
      exec = "${screenshotFull}";
      noDisplay = true;
      startupNotify = false;
      settings."X-KDE-GlobalAccel-CommandShortcut" = "true";
    };
  };

  programs.plasma.shortcuts = {
    "services/net.local.flameshot.desktop" = {
      "_launch" = "Print";
    };
    "services/net.local.flameshot-full.desktop" = {
      "_launch" = "Ctrl+Print";
    };
  };

  home.file."${config.services.flameshot.settings.General.savePath}/.init".text = "";
}
