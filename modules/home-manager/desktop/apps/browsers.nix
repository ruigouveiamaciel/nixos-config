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
          {directory = ".librewolf"; mode = "0700";}
          {directory = ".cache/librewolf"; mode = "0700";}
          {directory = ".config/chromium"; mode = "0700";}
          {directory = ".cache/chromium"; mode = "0700";}
        ];
      };
    })
    ++ (lib.optional (options ? "stylix") {
      stylix.targets.firefox.profileNames = ["smokewow"];
    })
  );
}
