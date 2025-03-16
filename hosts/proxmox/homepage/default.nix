{
  pkgs,
  config,
  ...
}: {
  imports = [../minimal-lxc];

  networking.hostName = "homepage";

  services.homepage-dashboard = {
    enable = true;
    package = pkgs.unstable.homepage-dashboard;
    openFirewall = true;
    listenPort = 8080;
    environmentFile = config.sops.templates."homepage.env".path;
    settings = {
      layout = [
        {
          "Main" = {
            header = false;
            style = "row";
            columns = 2;
            "Infrastructure" = {
            };
            "Media" = {
              "Media Management" = {
                header = false;
                style = "row";
                columns = 2;
              };
            };
          };
        }
      ];
    };
    services = [
      {
        "Main" = [
          {
            "Infrastructure" = [
              {
                "Proxmox" = {
                  icon = "proxmox-light";
                  href = "https://10.0.0.2:8006";
                  widget = {
                    type = "proxmox";
                    url = "https://10.0.0.2:8006";
                    node = "discovery";
                    username = "{{HOMEPAGE_VAR_PROXMOX_USERNAME}}";
                    password = "{{HOMEPAGE_VAR_PROXMOX_PASSWORD}}";
                  };
                };
              }
              {
                "Unifi" = {
                  icon = "unifi";
                  href = "https://10.0.0.30:8443";
                  widget = {
                    type = "unifi";
                    url = "https://10.0.0.30:8443";
                    username = "{{HOMEPAGE_VAR_UNIFI_USERNAME}}";
                    password = "{{HOMEPAGE_VAR_UNIFI_PASSWORD}}";
                  };
                };
              }
              {
                "pfSense" = {
                  icon = "pfsense";
                  href = "https://10.0.0.1";
                };
              }
              {
                "qBittorrent" = {
                  icon = "qbittorrent";
                  href = "http://10.0.102.5:8080";
                  widget = {
                    type = "qbittorrent";
                    url = "http://10.0.102.5:8080";
                    username = "{{HOMEPAGE_VAR_QBITTORRENT_USERNAME}}";
                    password = "{{HOMEPAGE_VAR_QBITTORRENT_PASSWORD}}";
                    enableLeechProgress = true;
                  };
                };
              }
            ];
          }
          {
            "Media" = [
              {
                "Jellyfin" = {
                  icon = "jellyfin";
                  description = "Media server";
                  href = "http://10.0.102.4:8096";
                  widget = {
                    type = "jellyfin";
                    url = "http://10.0.102.4:8096";
                    key = "{{HOMEPAGE_VAR_JELLYFIN_KEY}}";
                    enableBlocks = true;
                    fields = ["movies" "episodes"];
                    enableNowPlaying = true;
                    enableUser = false;
                    showEpisodeNumber = true;
                    expandOneStreamToTwoRows = false;
                  };
                };
              }
              {
                "Immich" = {
                  icon = "immich";
                  description = "Personal photos and videos";
                  href = "#";
                };
              }
              {
                "Media Management" = [
                  {
                    "Radarr" = {
                      icon = "radarr";
                      description = "Movie management";
                      href = "http://10.0.102.16:7878";
                      widget = {
                        type = "radarr";
                        url = "http://10.0.102.16:7878";
                        key = "{{HOMEPAGE_VAR_RADARR_KEY}}";
                        fields = ["wanted" "queued" "movies"];
                        enableQueue = false;
                      };
                    };
                  }
                  {
                    "Sonarr" = {
                      icon = "sonarr";
                      description = "Series management";
                      href = "http://10.0.102.16:8989";
                      widget = {
                        type = "sonarr";
                        url = "http://10.0.102.16:8989";
                        key = "{{HOMEPAGE_VAR_SONARR_KEY}}";
                        fields = ["wanted" "queued" "series"];
                        enableQueue = false;
                      };
                    };
                  }
                  {
                    "Bazarr" = {
                      icon = "bazarr";
                      description = "Subtitles management";
                      href = "http://10.0.102.16:6767";
                      widget = {
                        type = "bazarr";
                        url = "http://10.0.102.16:6767";
                        key = "{{HOMEPAGE_VAR_BAZARR_KEY}}";
                        fields = ["missingMovies" "missingEpisodes"];
                      };
                    };
                  }
                  {
                    "Prowlarr" = {
                      icon = "prowlarr";
                      description = "Indexer management";
                      href = "http://10.0.102.16:9696";
                      widget = {
                        type = "prowlarr";
                        url = "http://10.0.102.16:9696";
                        key = "{{HOMEPAGE_VAR_PROWLARR_KEY}}";
                        fields = ["numberOfGrabs" "numberOfFailGrabs"];
                      };
                    };
                  }
                ];
              }
            ];
          }
        ];
      }
    ];
    bookmarks = [
      {
        Developer = [
          {
            Github = [
              {
                abbr = "GH";
                href = "https://github.com/";
              }
            ];
          }
        ];
      }
      {
        Entertainment = [
          {
            YouTube = [
              {
                abbr = "YT";
                href = "https://youtube.com/";
              }
            ];
          }
        ];
      }
    ];
  };

  sops = {
    secrets = {
      proxmox-username.sopsFile = ./secrets.yaml;
      proxmox-password.sopsFile = ./secrets.yaml;
      unifi-username.sopsFile = ./secrets.yaml;
      unifi-password.sopsFile = ./secrets.yaml;
      qbittorrent-username.sopsFile = ./secrets.yaml;
      qbittorrent-password.sopsFile = ./secrets.yaml;
      jellyfin-key.sopsFile = ./secrets.yaml;
      radarr-key.sopsFile = ./secrets.yaml;
      sonarr-key.sopsFile = ./secrets.yaml;
      bazarr-key.sopsFile = ./secrets.yaml;
      prowlarr-key.sopsFile = ./secrets.yaml;
    };

    templates."homepage.env" = {
      restartUnits = ["homepage-dashboard.service"];
      content = ''
        HOMEPAGE_VAR_PROXMOX_USERNAME=${config.sops.placeholder.proxmox-username}
        HOMEPAGE_VAR_PROXMOX_PASSWORD=${config.sops.placeholder.proxmox-password}
        HOMEPAGE_VAR_UNIFI_USERNAME=${config.sops.placeholder.unifi-username}
        HOMEPAGE_VAR_UNIFI_PASSWORD=${config.sops.placeholder.unifi-password}
        HOMEPAGE_VAR_QBITTORRENT_USERNAME=${config.sops.placeholder.qbittorrent-username}
        HOMEPAGE_VAR_QBITTORRENT_PASSWORD=${config.sops.placeholder.qbittorrent-password}
        HOMEPAGE_VAR_JELLYFIN_KEY=${config.sops.placeholder.jellyfin-key}
        HOMEPAGE_VAR_RADARR_KEY=${config.sops.placeholder.radarr-key}
        HOMEPAGE_VAR_SONARR_KEY=${config.sops.placeholder.sonarr-key}
        HOMEPAGE_VAR_BAZARR_KEY=${config.sops.placeholder.bazarr-key}
        HOMEPAGE_VAR_PROWLARR_KEY=${config.sops.placeholder.prowlarr-key}
      '';
    };
  };
}
