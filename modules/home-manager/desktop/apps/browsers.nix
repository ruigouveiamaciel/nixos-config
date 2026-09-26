{
  pkgs,
  lib,
  options,
  ...
}: {
  config = lib.mkMerge (
    [
      {
        home.packages = with pkgs; [
          ungoogled-chromium # For those rare occasions that I need a chrome browser
        ];

        programs.librewolf = {
          enable = true;
          configPath = ".librewolf";
          profiles.smokewow = {
            id = 0;
            isDefault = true;
            settings = {
              "privacy.sanitize.sanitizeOnShutdown" = true;
              "privacy.clearOnShutdown.history" = true;
              "privacy.clearOnShutdown.downloads" = true;
              "privacy.clearOnShutdown.formdata" = true;
              "privacy.clearOnShutdown.cache" = true;
              "privacy.clearOnShutdown.openWindows" = true;
              "privacy.clearOnShutdown.cookies" = false;
              "privacy.clearOnShutdown.sessions" = false;
              "privacy.clearOnShutdown.offlineApps" = false;
              "privacy.clearOnShutdown.siteSettings" = false;
              "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = true;
              "privacy.clearOnShutdown_v2.cache" = true;
              "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
              "privacy.clearOnShutdown_v2.formdata" = true;
              "privacy.clearOnShutdown_v2.historyFormDataAndDownloads" = true;
              "privacy.clearOnShutdown_v2.siteSettings" = false;
            };
          };
        };

        xdg.mimeApps = {
          enable = true;
          defaultApplications = {
            "text/html" = "librewolf.desktop";
            "x-scheme-handler/http" = "librewolf.desktop";
            "x-scheme-handler/https" = "librewolf.desktop";
            "x-scheme-handler/about" = "librewolf.desktop";
            "x-scheme-handler/unknown" = "librewolf.desktop";
          };
        };
      }
    ]
    ++ (lib.optional (options.home ? "persistence") {
      home.persistence."/persist" = {
        directories = [
          {
            directory = ".mozilla/firefox";
            mode = "0700";
          }
          {
            directory = ".librewolf";
            mode = "0700";
          }
          {
            directory = ".cache/librewolf";
            mode = "0700";
          }
          {
            directory = ".config/chromium";
            mode = "0700";
          }
          {
            directory = ".cache/chromium";
            mode = "0700";
          }
        ];
      };
    })
  );
}
