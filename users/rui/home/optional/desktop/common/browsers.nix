{
  pkgs,
  config,
  ...
}: {
  programs.firefox = {
    enable = true;
  };

  programs.chromium = {
    enable = true;
    package = pkgs.google-chrome;
  };

  programs.qutebrowser = {
    enable = true;
  };

  home.persistence."/nix/persist${config.home.homeDirectory}" = {
    allowOther = true;
    directories = [
      ".cache/mozilla/firefox"
      ".cache/qutebrowser"
      ".cache/google-chrome"
      ".mozilla/firefox"
      ".config/google-chrome"
      ".config/qutebrowser"
      ".local/share/qutebrowser"
    ];
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = ["google-chrome.desktop"];
    "text/xml" = ["google-chrome.desktop"];
    "x-scheme-handler/http" = ["google-chrome.desktop"];
    "x-scheme-handler/https" = ["google-chrome.desktop"];
  };
}
