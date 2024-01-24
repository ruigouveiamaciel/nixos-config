{
  pkgs,
  config,
  ...
}: {
  home = {
    packages = with pkgs; [
      slack
    ];
    persistence."/nix/persist${config.home.homeDirectory}" = {
      directories = [
        ".config/Slack"
      ];
    };
  };

  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/slack" = "slack.desktop";
  };
}
