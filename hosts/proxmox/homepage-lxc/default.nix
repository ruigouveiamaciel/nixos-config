{
  pkgs,
  config,
  ...
}: let
  services = config.myNixOS.services.discovery.default;
in {
  imports = [../minimal-lxc];

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
              href = services.vikunja.http;
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
              href = services.paperless.http;
              widget = {
                type = "paperlessngx";
                url = href;
                key = "{{HOMEPAGE_VAR_PAPERLESS_KEY}}";
              };
            };
          }
          {
            "Downloads & Storage" = [
              #{
              #"Filebrowser" = {
              #icon = "filebrowser";
              #description = "Web-based file explorer";
              #href = services.nfs.http;
              #};
              #}
              {
                "Flood" = rec {
                  icon = "flood";
                  description = "Torrent client";
                  href = services.flood.http;
                  widget = {
                    type = "flood";
                    url = href;
                    username = "{{HOMEPAGE_VAR_FLOOD_USERNAME}}";
                    password = "{{HOMEPAGE_VAR_FLOOD_PASSWORD}}";
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
              href = services.jellyfin.http;
              widget = {
                type = "jellyfin";
                url = href;
                key = "{{HOMEPAGE_VAR_JELLYFIN_KEY}}";
                enableBlocks = true;
                fields = ["movies" "episodes"];
                enableNowPlaying = true;
                enableUser = true;
                showEpisodeNumber = true;
                expandOneStreamToTwoRows = false;
              };
            };
          }
          {
            "Immich" = rec {
              icon = "immich";
              description = "Personal photos and videos";
              href = services.immich.http;
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
              href = services.jellyseerr.http;
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
              href = services.radarr.http;
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
              href = services.sonarr.http;
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
              href = services.bazarr.http;
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
              href = services.prowlarr.http;
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
            "Terminal" = {
              icon = "terminal";
              description = "Browser-rendered terminal on a development container";
              href = services.devbox.http;
            };
          }
          {
            "pfSense" = {
              icon = "pfsense";
              description = "Firewall and router";
              href = services.pfSense.http;
            };
          }
          {
            "Proxmox" = rec {
              icon = "proxmox-light";
              description = "Virtualization and container management";
              href = services.proxmox.http;
              widget = {
                type = "proxmox";
                url = href;
                node = "alpha";
                username = "{{HOMEPAGE_VAR_PROXMOX_USERNAME}}";
                password = "{{HOMEPAGE_VAR_PROXMOX_PASSWORD}}";
              };
            };
          }
          {
            "Unifi" = rec {
              icon = "unifi";
              description = "Network management and monitoring";
              href = services.unifi.http;
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
      flood-username.sopsFile = ./secrets.yaml;
      flood-password.sopsFile = ./secrets.yaml;
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
        HOMEPAGE_VAR_FLOOD_USERNAME=${config.sops.placeholder.flood-username}
        HOMEPAGE_VAR_FLOOD_PASSWORD=${config.sops.placeholder.flood-password}
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
