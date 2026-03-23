{
  pkgs,
  lib,
  options,
  ...
}: {
  config = lib.mkMerge (
    [
      {
        home.packages = with pkgs; [ungoogled-chromium];

        programs.firefox = {
          enable = true;
          package = pkgs.librewolf;
          profiles.smokewow = {
            id = 0;
            isDefault = true;
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
          ".librewolf"
          ".cache/librewolf"
          ".config/chromium"
          ".cache/chromium"
        ];
      };
    })
    ++ (lib.optional (options ? "stylix") {
      stylix.targets.firefox.profileNames = ["smokewow"];
    })
  );
}
