{
  lib,
  pkgs,
  options,
  ...
}: {
  config = lib.mkMerge (
    [
      {
        programs = {
          chromium = {
            enable = true;
            package = pkgs.brave;
            extensions = [
              {id = "mnjggcdmjocbbbhaepdhchncahnbgone";} # SponsorBlock
              {id = "ghmbeldphafepmbegfdlkpapadhbakde";} # Proton Pass
            ];
          };
          librewolf = {
            enable = true;
            configPath = ".librewolf";
            policies = {
              ExtensionSettings = {
                # Proton Pass
                "78272b6fa58f4a1abaac99321d503a20@proton.me" = {
                  installation_mode = "force_installed";
                  install_url = "https://addons.mozilla.org/firefox/downloads/latest/proton-pass/addon.xpi";
                  private_browsing = true;
                };
                # uBlock Origin
                "uBlock0@raymondhill.net" = {
                  installation_mode = "force_installed";
                  install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/addon.xpi";
                  private_browsing = true;
                };
                # Bypass Paywalls Clean
                "magnolia@12.34" = {
                  installation_mode = "force_installed";
                  install_url = "https://gitflic.ru/project/magnolia1234/bpc_uploads/blob/raw?file=bypass_paywalls_clean-latest.xpi";
                  private_browsing = true;
                };
                # YouTube Anti Translate
                "{458160b9-32eb-4f4c-87d1-89ad3bdeb9dc}" = {
                  installation_mode = "force_installed";
                  install_url = "https://addons.mozilla.org/firefox/downloads/latest/youtube-anti-translate/addon.xpi";
                  private_browsing = true;
                };
                # SponsorBlock
                "sponsorBlocker@ajay.app" = {
                  installation_mode = "force_installed";
                  install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/addon.xpi";
                  private_browsing = true;
                };
              };
              HttpAllowlist = [
                "http://10.0.0.1" # OpenWrt
                "http://10.0.50.42:8096" # Jellyfin
                "http://10.0.50.42:2283" # Immich
                "http://10.0.50.42:4533" # Navidrome
                "http://10.0.50.42:5055" # Seerr
                "http://10.0.50.42:8989" # Sonarr
                "http://10.0.50.42:7878" # Radarr
                "http://10.0.50.42:8686" # Lidarr
                "http://10.0.50.42:6767" # Bazarr
                "http://10.0.50.42:9696" # Prowlarr
                "http://10.0.50.42:1338" # qBittorrent
                "http://10.0.50.42:1337" # Flood
                "http://10.0.50.42:8191" # FlareSolverr
                "http://10.0.50.123:8123" # Home Assistant
                "http://10.0.50.124:8080" # Zigbee2MQTT
                "http://10.0.50.42:1619" # Paperless
                "http://10.0.50.42:8280" # Tiny Tiny RSS
                "http://10.0.50.42:1601" # Fava
                "http://10.0.50.42:8888" # SearXNG
                "http://10.0.50.42:8337" # OpenSpeedTest
                "http://10.0.50.42:8069" # Hompeage
              ];
            };
            profiles.smokewow = {
              id = 0;
              isDefault = true;
              search = {
                force = true;
                default = "kagi";
                privateDefault = "kagi";
                order = ["kagi" "searxng"];
                engines.kagi = {
                  name = "Kagi";
                  urls = [
                    {
                      template = "https://kagi.com/search";
                      params = [
                        {
                          name = "q";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];
                  icon = "https://kagi.com/favicon.ico";
                  definedAliases = ["@k"];
                };
                engines.nixos-packages = {
                  name = "NixOS Packages";
                  urls = [
                    {
                      template = "https://search.nixos.org/packages";
                      params = [
                        {
                          name = "query";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];
                  icon = "https://search.nixos.org/favicon.ico";
                  definedAliases = ["@pkgs"];
                };
                engines.nixos-options = {
                  name = "NixOS Options";
                  urls = [
                    {
                      template = "https://search.nixos.org/options";
                      params = [
                        {
                          name = "query";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];
                  icon = "https://search.nixos.org/favicon.ico";
                  definedAliases = ["@opts"];
                };
              };
              settings = {
                "privacy.sanitize.sanitizeOnShutdown" = true;
                "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = true;
                "privacy.clearOnShutdown_v2.cache" = true;
                "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
                "privacy.clearOnShutdown_v2.formdata" = true;
                "privacy.clearOnShutdown_v2.historyFormDataAndDownloads" = true;
                "privacy.clearOnShutdown_v2.siteSettings" = false;
                "browser.translations.automaticallyPopup" = false;
                "browser.translations.enable" = false;
                "middlemouse.paste" = false;
                "middlemouse.contentLoadURL" = false;
                "signon.rememberSignons" = false;
                "signon.management.page.breach-alerts.enabled" = false;
                "privacy.userContext.enabled" = false;
                "privacy.userContext.ui.enabled" = false;
                "browser.startup.page" = 1;
                "browser.startup.homepage" = "http://10.0.50.42:8069";
              };
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
            directory = ".librewolf";
            mode = "0700";
          }
          {
            directory = ".cache/librewolf";
            mode = "0700";
          }
          {
            directory = ".config/BraveSoftware";
            mode = "0700";
          }
          {
            directory = ".cache/BraveSoftware";
            mode = "0700";
          }
        ];
      };
    })
  );
}
