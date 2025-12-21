{
  inputs,
  outputs,
  myModulesPath,
  ...
}: {
  containers.homepage = {
    autoStart = true;
    macvlans = ["enp90s0"];
    bindMounts."/persist/ssh_host_ed25519_key".isReadOnly = true;
    privateNetwork = true;
    specialArgs = {
      inherit inputs outputs myModulesPath;
    };
    config = {
      pkgs,
      config,
      inputs,
      myModulesPath,
      ...
    }: {
      imports = [
        inputs.sops-nix.nixosModules.sops
        "${myModulesPath}/system/nixpkgs.nix"
      ];

      system.stateVersion = "25.11";

      networking = {
        interfaces."mv-enp90s0" = {
          useDHCP = false;
          ipv4.addresses = [
            {
              address = "10.0.50.254";
              prefixLength = 24;
            }
          ];
        };
        defaultGateway = "10.0.50.1";
        nameservers = ["10.0.50.1"];
        useHostResolvConf = false;
      };

      services.homepage-dashboard = {
        enable = true;
        package = pkgs.unstable.homepage-dashboard;
        openFirewall = true;
        listenPort = 8080;
        environmentFile = config.sops.templates."homepage.env".path;
        allowedHosts = "10.0.50.254:8080";
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
                "Paperless" = rec {
                  icon = "paperless-ngx";
                  description = "Smart document management";
                  href = "";
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
                    "Flood" = rec {
                      icon = "flood";
                      description = "Torrent client";
                      href = "http://10.0.50.37:3000";
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
                  href = "http://10.0.50.10:8096";
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
                  href = "";
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
                  href = "http://10.0.50.55:5055";
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
                  href = "http://10.0.50.78:7878";
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
                  href = "http://10.0.50.89:8989";
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
                  href = "http://10.0.50.67:6767";
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
                  href = "http://10.0.50.96:9696";
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
            "Infrastructure" = [
              {
                "OpenWrt" = rec {
                  icon = "openwrt";
                  description = "Firewall and router";
                  href = "http://10.0.0.1";
                  widget = {
                    type = "openwrt";
                    url = href;
                    username = "{{HOMEPAGE_VAR_OPENWRT_USERNAME}}";
                    password = "{{HOMEPAGE_VAR_OPENWRT_PASSWORD}}";
                    interfaceName = "wan";
                  };
                };
              }
              {
                "Unifi" = rec {
                  icon = "unifi";
                  description = "Network management and monitoring";
                  href = "https://10.0.50.253:8443";
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
      };

      sops = {
        useTmpfs = true;
        age.sshKeyPaths = ["/persist/ssh_host_ed25519_key"];
        secrets = {
          jellyfin-key.sopsFile = ../secrets.yaml;
          jellyseerr-key.sopsFile = ../secrets.yaml;
          prowlarr-key.sopsFile = ../secrets.yaml;
          bazarr-key.sopsFile = ../secrets.yaml;
          sonarr-key.sopsFile = ../secrets.yaml;
          radarr-key.sopsFile = ../secrets.yaml;
          openwrt-username.sopsFile = ../secrets.yaml;
          openwrt-password.sopsFile = ../secrets.yaml;
          unifi-username.sopsFile = ../secrets.yaml;
          unifi-password.sopsFile = ../secrets.yaml;
          flood-username.sopsFile = ../secrets.yaml;
          flood-password.sopsFile = ../secrets.yaml;
          immich-key.sopsFile = ../secrets.yaml;
          paperless-key.sopsFile = ../secrets.yaml;
        };

        templates."homepage.env" = {
          restartUnits = ["homepage-dashboard.service"];
          content = ''
            HOMEPAGE_VAR_JELLYFIN_KEY=${config.sops.placeholder.jellyfin-key}
             HOMEPAGE_VAR_UNIFI_USERNAME=${config.sops.placeholder.unifi-username}
             HOMEPAGE_VAR_UNIFI_PASSWORD=${config.sops.placeholder.unifi-password}
             HOMEPAGE_VAR_FLOOD_USERNAME=${config.sops.placeholder.flood-username}
             HOMEPAGE_VAR_FLOOD_PASSWORD=${config.sops.placeholder.flood-password}
             HOMEPAGE_VAR_OPENWRT_USERNAME=${config.sops.placeholder.openwrt-username}
             HOMEPAGE_VAR_OPENWRT_PASSWORD=${config.sops.placeholder.openwrt-password}
             HOMEPAGE_VAR_JELLYFIN_KEY=${config.sops.placeholder.jellyfin-key}
             HOMEPAGE_VAR_RADARR_KEY=${config.sops.placeholder.radarr-key}
             HOMEPAGE_VAR_SONARR_KEY=${config.sops.placeholder.sonarr-key}
             HOMEPAGE_VAR_BAZARR_KEY=${config.sops.placeholder.bazarr-key}
             HOMEPAGE_VAR_PROWLARR_KEY=${config.sops.placeholder.prowlarr-key}
             HOMEPAGE_VAR_JELLYSEERR_KEY=${config.sops.placeholder.jellyseerr-key}
             HOMEPAGE_VAR_IMMICH_KEY=${config.sops.placeholder.immich-key}
             HOMEPAGE_VAR_PAPERLESS_KEY=${config.sops.placeholder.paperless-key}
          '';
        };
      };
    };
  };
}
