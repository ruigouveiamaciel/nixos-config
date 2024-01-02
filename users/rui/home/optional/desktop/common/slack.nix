{
  pkgs,
  config,
  ...
}: {
  home = {
    packages = with pkgs; [
      unstable.slack
    ];
    persistence."/nix/persist${config.home.homeDirectory}" = {
      allowOther = true;
      directories = [
        ".config/Slack"
      ];
    };
  };

  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/slack" = "slack.desktop";
  };
}
