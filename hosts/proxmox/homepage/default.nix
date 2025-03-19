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
      headerStyle = "clean";
      useEqualHeights = true;
      hideVersion = true;
      disableUpdateCheck = true;
    };
    services = [
      {
        "Productivity & Documents" = [
          {
            "Vikunja" = rec {
              icon = "vikunja";
              description = "Tasks and project management";
              href = "http://10.0.102.6:3456";
              widget = {
                type = "vikunja";
                url = href;
                key = "{{HOMEPAGE_VAR_VIKUNJA_KEY}}";
                enableTaskList = false;
                fields = ["tasks7d" "tasksOverdue"];
              };
            };
          }
          {
            "Paperless" = rec {
              icon = "paperless-ngx";
              description = "Smart document management";
              href = "http://10.0.102.7:8000";
              widget = {
                type = "paperlessngx";
                url = href;
                key = "{{HOMEPAGE_VAR_PAPERLESS_KEY}}";
              };
            };
          }
          {
            "Downloads & Storage" = [
              {
                "Filebrowser" = {
                  icon = "filebrowser";
                  description = "Web-based file explorer";
                  href = "http://10.0.102.3:8080";
                };
              }
              {
                "qBittorrent" = rec {
                  icon = "qbittorrent";
                  description = "BitTorrent client";
                  href = "http://10.0.102.5:8080";
                  widget = {
                    type = "qbittorrent";
                    url = href;
                    username = "{{HOMEPAGE_VAR_QBITTORRENT_USERNAME}}";
                    password = "{{HOMEPAGE_VAR_QBITTORRENT_PASSWORD}}";
                    enableLeechProgress = true;
                  };
                };
              }
            ];
          }
        ];
      }
      {
        "Media Streaming & Libraries" = [
          {
            "Jellyfin" = rec {
              icon = "jellyfin";
              description = "Media streaming server for movies and TV shows";
              href = "http://10.0.102.4:8096";
              widget = {
                type = "jellyfin";
                url = href;
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
            "Immich" = rec {
              icon = "immich";
              description = "Personal photos and videos";
              href = "http://10.0.102.4:2283";
              widget = {
                type = "immich";
                url = href;
                key = "{{HOMEPAGE_VAR_IMMICH_KEY}}";
                version = 2;
                fields = ["photos" "videos"];
              };
            };
          }
        ];
      }
      {
        "Media Requests" = [
          {
            "Jellyseerr" = rec {
              icon = "jellyseerr";
              description = "Discover and request movies and TV shows";
              href = "http://10.0.102.16:5055";
              widget = {
                type = "jellyseerr";
                url = href;
                key = "{{HOMEPAGE_VAR_JELLYSEERR_KEY}}";
                fields = ["pending" "approved" "available"];
              };
            };
          }
          {
            "Radarr" = rec {
              icon = "radarr";
              description = "Automated movie management";
              href = "http://10.0.102.16:7878";
              widget = {
                type = "radarr";
                url = href;
                key = "{{HOMEPAGE_VAR_RADARR_KEY}}";
                fields = ["wanted" "queued" "movies"];
                enableQueue = false;
              };
            };
          }
          {
            "Sonarr" = rec {
              icon = "sonarr";
              description = "Automated TV show management";
              href = "http://10.0.102.16:8989";
              widget = {
                type = "sonarr";
                url = href;
                key = "{{HOMEPAGE_VAR_SONARR_KEY}}";
                fields = ["wanted" "queued" "series"];
                enableQueue = false;
              };
            };
          }
          {
            "Bazarr" = rec {
              icon = "bazarr";
              description = "Subtitles downloader and manager";
              href = "http://10.0.102.16:6767";
              widget = {
                type = "bazarr";
                url = href;
                key = "{{HOMEPAGE_VAR_BAZARR_KEY}}";
                fields = ["missingMovies" "missingEpisodes"];
              };
            };
          }
          {
            "Prowlarr" = rec {
              icon = "prowlarr";
              description = "Indexer manager";
              href = "http://10.0.102.16:9696";
              widget = {
                type = "prowlarr";
                url = href;
                key = "{{HOMEPAGE_VAR_PROWLARR_KEY}}";
                fields = ["numberOfGrabs" "numberOfFailGrabs"];
              };
            };
          }
        ];
      }
      {
        "Infrastructure & Networking" = [
          {
            "pfSense" = {
              icon = "pfsense";
              description = "Firewall and router";
              href = "https://10.0.0.1";
            };
          }
          {
            "Proxmox" = rec {
              icon = "proxmox-light";
              description = "Virtualization and container management";
              href = "https://10.0.0.2:8006";
              widget = {
                type = "proxmox";
                url = href;
                node = "discovery";
                username = "{{HOMEPAGE_VAR_PROXMOX_USERNAME}}";
                password = "{{HOMEPAGE_VAR_PROXMOX_PASSWORD}}";
              };
            };
          }
          {
            "Unifi" = rec {
              icon = "unifi";
              description = "Network management and monitoring";
              href = "https://10.0.0.30:8443";
              widget = {
                type = "unifi";
                url = href;
                username = "{{HOMEPAGE_VAR_UNIFI_USERNAME}}";
                password = "{{HOMEPAGE_VAR_UNIFI_PASSWORD}}";
              };
            };
          }
        ];
      }
    ];
    bookmarks = [];
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
      jellyseerr-key.sopsFile = ./secrets.yaml;
      immich-key.sopsFile = ./secrets.yaml;
      paperless-key.sopsFile = ./secrets.yaml;
      vikunja-key.sopsFile = ./secrets.yaml;
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
        HOMEPAGE_VAR_JELLYSEERR_KEY=${config.sops.placeholder.jellyseerr-key}
        HOMEPAGE_VAR_IMMICH_KEY=${config.sops.placeholder.immich-key}
        HOMEPAGE_VAR_PAPERLESS_KEY=${config.sops.placeholder.paperless-key}
        HOMEPAGE_VAR_VIKUNJA_KEY=${config.sops.placeholder.vikunja-key}
      '';
    };
  };
}
