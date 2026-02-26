{
  pkgs,
  config,
  ...
}: {
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

  home.file."${config.services.flameshot.settings.General.savePath}/.init".text = "";
}
