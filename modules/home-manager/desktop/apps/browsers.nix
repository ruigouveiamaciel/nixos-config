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
          ungoogled-chromium
        ];

        programs.librewolf = {
          enable = true;
          configPath = ".librewolf";
          policies = {
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
              default = "searxng";
              privateDefault = "searxng";
              order = ["searxng"];
              engines.searxng = {
                name = "SearXNG";
                urls = [
                  {
                    template = "http://10.0.50.42:8888/search";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                      {
                        name = "language";
                        value = "en";
                      }
                      {
                        name = "categories";
                        value = "general,it";
                      }
                      {
                        name = "safesearch";
                        value = "0";
                      }
                      {
                        name = "preferences";
                        value = "eJx1WMmS67oN_Zp4o3pd9-VmqCy8SiXvA_L2KoiEJV5RhJqDbfbXB6Qm0nIvetChCIIYDgAJ8NiTVeiuPRq0oC8aTB-gxyuaiyYBOv8HwZOgadbo8doT9RovN7grQaa16Ejf0V4vauKN7WzpGa9_2oCXCf1A8vrHf_68OLihQ7BiuP64-AEnvDqVBF54f9DetSzK4KP10F3_C9rhRZI6hBPw4wfZ_rJsa52PrJsEO14EGo-2Ba16M_H_y-GfAW1slWm98vzmInNRIZ0llrvH1qFGse4ZyI8Y3fWupkuwur2RncB7ZfrrbNH7eJHKQadRtmh6ZdhwP__xYxXarjb8y1__vYPNXUkk17bLX176-48f87NtiW1g-fFfPfRt60go0M2EUgGD0AkTB0yXKoSCuAVTSAI9swaNViY8mxnEyNbnk5RPa8ZBm-yZX5zHZlLWkt1WZ7Zgw78b58nivgfYnxK2R-uV4P-TU93y7Dx4xbYrwEilih0oGU5As7xebFvgEdRtO61TWqWf4n4dm72Sxc9vRCU0XXS_bkZOdu-UF0PwWENdECP6TQcCKy2CrO1ewS-e6uauetVL1bPSN6WzcjSj4eh1WCict34IIT5kqYwAMcSG3KsnxYC3kVJ4bSEjLDln8cbKCIVG4II95F1x_hTaRJzLR4n4la4wBadEfs7-dIdkiTmlS_NK2TcSb8qo5HlXyuOjo9B0jn5kZZQsxLKR009PzQMrexUrJ8cWaydnVhIhHXOctgT3BDNv4N9Jn4l-qTmZ_XiLcxojlrr8XmTlDZzvyJfLN2kpXSo7he0hs48PV-_Q-SbH0ukix1L2yuGctOAH8BMzZSXKYgdaV5qtWJ0FO3o-U7PXRZXGN63EaEvAIjaObv4BFhvJsoRPZLle3yozKijZ4RaNrJSKsYiAHjowX1C-0KP6GpiTi5fQqOAOE_CzJ1qP7NU8xOK8nkkdun3RI6cUTdvz9KyOIsr5W56Va9jLS4ycnbfiJyuuuHDf75k1xMSyWyqX8EScraU8rjNoE7W8ZuAAnYX0a5UyMD-gXXy9APjcuMKyEPehNqMN6y3zQ5KrbqUNlW5mcn4PmSH0XNP6G4htT4E0Ejw49O7NkmPO2glLTbI7DK2mPpSBpQwUl-astMwslVKfKpZV4JdyAx3yRg5UcEXeaZym2LDvp5A4KqnxwtHLG8ExD3-zlqzw3VqSzIH4ZlmxX2xsUgg5VWrEZrlXsa6pcx4_7GYiHYSSVU2Ann2T8n-758QMRJLMN3rvywO4wUP_5g30IGYw65GTSmWDE7rRzNcH-mQGD_JIuom-BlXqPj2mrqIbkwNJUOEjEwGKoiejw7K0kdYwbYU-lUTuKp9l9UrYas7ypATzNbBwf4IszlSYe6mXym1VfMYnlrQyK_ErTB2VSOoXMe_YPDCrlDsdxEKwejJtxT29j-0LfqKEmaRgf5TFaA4dl_n7qtpn4Ha1vGEGzvzx-QBTFZ8M1Py-QO-3nlWzyK2PPXZb8j7RK7MOlXdbivkUnfIVO3KTfBucP5GTw1nB1gHsp3HGzkw1qbsUYyGceqq6wwyc77DApzss8APZxgdn5SOcgbloANwYumB8WK3OLbsIzn3MkaeRLfIFSBk_NtrYCtusfhtI4xm36g4iPl4qbwGfb1Eunu7iaYzkiQ01phTdQo6HHSW50NqFcTbYJ5GO711Zr0RXa_iKe31w47k7O9CzzsXaWeVjrQrEYBxXNFc0qBGMxKoCL8j5vBV_6X0iDFSNFRKUjhMts8euEA9pWLLQQ3UVfTzUqDqi0b2CbkaRC8U38EFMCU79e46E4m3SN8uUpueh4nmphP8iU2XOFLmF49ap8ZaHMm69sOqTfv_585_Pw9MySDRlOn4ZmCpxqW-YlU7N6faWyVMZc_896PRemqN8zAW7A7fVcgP3eq7JwNknC1y5eIHOpBK62OPkduJF60NXMn8uRqzlmEaT3PvvS5Fzow4REc_KWGZujRWR6fQpoNy5fEAYgnmZl0v8DcnkUK5T40FPNZJhxm5cNGRi6r33bCLyqSt_MwWG5yPPqrvwO48KeS5fTXMPQ7iXJ2XgrNQCnwydwnDiEayU8AVzKvHV9GnZTyfg4zwyZ_g8IWe4cryjYAXy2LxNyP5vxXQ7j_1HT0V9c2icsNyFfYbCcKw5cmfKrUe6x4pfuAuovqOAMeCa5BOVLrGdkflm-cSx7F5iWT15Ui4AsE91LzOX5w0pYJoPVklvr0PgYSEREtfWkSgpNdjNELbxAoPlvmOexCs1pAx7P85-M-RWxkXPnMZ9jylsxZPMca4giR3avh4fKhnHFPJmluHaQBpsqfUktwJo5m1amoCHOdzGi9yf8bx3tPt1n5bWuKvhgRHWLwL1uvM8OvopFeRl-p5looTjpXngwmf21SyqkdyJKLMkxBEERy0N3ZR4s5AS5833FqSiprP0cOXnDY5dDoG6u3XcE4_EZHbT9NiCNvAQEtxuAIdsEB6Q35mPu_hEx3uho_BCeDtSRl3lsQR8Bqrbq1x-cq69oJnYU1e8HZkrEsX0ofVlf-pZ2B_ndC8X31LLtghBptGxVH1bevnY8SArjSpau4f39kMVlYvb-XXeOT6ZzjpwrrsrNzitGFCMOwlsKwK0CFwjKYlIo826ktsM5VvuPtl5fhkFoF2-ED-YcZJzuMCmxG3Th1vLNfe-DKAmf7zC__H8o7dWtmWU0hZuIdpUsS_ckHHsXv8PyViyrw==";
                      }
                    ];
                  }
                ];
                icon = "http://10.0.50.42:8888/static/themes/simple/img/favicon.png";
                definedAliases = ["@sx"];
              };
            };
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
