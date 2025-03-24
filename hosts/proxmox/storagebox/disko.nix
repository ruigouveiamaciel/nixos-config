{
  config,
  pkgs,
  ...
}: let
  services = config.myNixOS.services.discovery.default;
in {
  imports = [../minimal-vm/disko.nix];

  boot = {
    supportedFilesystems = ["zfs"];
    kernelModules = ["zfs"];
    extraModprobeConfig = "options zfs zfs_arc_max=2147483648";
    zfs = {
      devNodes = "/dev/disk/by-partlabel";
      forceImportRoot = false;
    };
  };
  environment.systemPackages = with pkgs; [zfs];

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot = {
      enable = true;
      frequent = false;
    };
  };

  services.zfs = {
    zed.settings = {
      ZED_USE_ENCLOSURE_LEDS = true;
      ZED_SCRUB_AFTER_RESILVER = true;
    };
  };

  disko.devices = {
    disk = {
      hdd1 = {
        device = "/dev/disk/by-id/ata-WDC_WD80EFPX-68C4ZN0_WD-RD1H1GJD";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zdata1";
              };
            };
          };
        };
      };
      hdd2 = {
        device = "/dev/disk/by-id/ata-WDC_WD80EFPX-68C4ZN0_WD-RD1JAYXD";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zdata1";
              };
            };
          };
        };
      };
    };

    zpool = {
      zdata1 = let
        ROOT_MOUNTPOINT = "/export";
        DEFAULT_NFS_SETTINGS = "nohide,insecure,no_subtree_check,all_squash";
      in {
        type = "zpool";
        mode = {
          topology = {
            type = "topology";
            vdev = [
              {
                mode = "mirror";
                members = ["hdd1" "hdd2"];
              }
            ];
          };
        };
        options = {
          ashift = "12";
        };
        rootFsOptions = {
          compression = "zstd";
          xattr = "sa";
          canmount = "on";
          atime = "off";
          "com.sun:auto-snapshot" = "true"; # By default, snapshot everything
          sharenfs = "off"; # By default, do not share on nfs
        };
        mountpoint = ROOT_MOUNTPOINT;
        datasets = {
          downloads = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/downloads";
            options = {
              compression = "off";
              recordsize = "1M";
              logbias = "throughput";
              "com.sun:auto-snapshot" = "false";
              sharenfs = builtins.concatStringsSep "," [
                "rw=${services.qbittorrent.ip}"
                "rw=${services.radarr.ip}"
                "rw=${services.sonarr.ip}"
                "rw=${services.devbox.ip}"
                DEFAULT_NFS_SETTINGS
              ];
            };
          };

          media_movies = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/media/movies";
            options = {
              compression = "lz4";
              recordsize = "1M";
              logbias = "throughput";
              "com.sun:auto-snapshot" = "false";
              sharenfs = builtins.concatStringsSep "," [
                "rw=${services.radarr.ip}"
                "ro=${services.jellyfin.ip}"
                "rw=${services.devbox.ip}"
                DEFAULT_NFS_SETTINGS
              ];
            };
          };

          media_tvshows = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/media/tvshows";
            options = {
              compression = "lz4";
              recordsize = "1M";
              logbias = "throughput";
              "com.sun:auto-snapshot" = "false";
              sharenfs = builtins.concatStringsSep "," [
                "rw=${services.sonarr.ip}"
                "ro=${services.jellyfin.ip}"
                "rw=${services.devbox.ip}"
                DEFAULT_NFS_SETTINGS
              ];
            };
          };

          media_anime = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/media/anime";
            options = {
              compression = "lz4";
              recordsize = "1M";
              logbias = "throughput";
              "com.sun:auto-snapshot" = "false";
              sharenfs = builtins.concatStringsSep "," [
                "rw=${services.sonarr.ip}"
                "ro=${services.jellyfin.ip}"
                "rw=${services.devbox.ip}"
                DEFAULT_NFS_SETTINGS
              ];
            };
          };

          media_personal = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/media/personal";
            options = {
              compression = "lz4";
              recordsize = "1M";
              logbias = "throughput";
              sharenfs = builtins.concatStringsSep "," [
                "ro=${services.jellyfin.ip}"
                "rw=${services.devbox.ip}"
                DEFAULT_NFS_SETTINGS
              ];
            };
          };

          service_immich = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/services/immich";
            options = {
              sharenfs = builtins.concatStringsSep "," [
                "rw=${services.immich.ip}"
                "rw=${services.devbox.ip}"
                DEFAULT_NFS_SETTINGS
              ];
            };
          };

          service_jellyfin = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/services/jellyfin";
            options = {
              sharenfs = builtins.concatStringsSep "," [
                "rw=${services.jellyfin.ip}"
                "rw=${services.devbox.ip}"
                DEFAULT_NFS_SETTINGS
              ];
            };
          };

          service_jellyseerr = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/services/jellyseerr";
            options = {
              sharenfs = builtins.concatStringsSep "," [
                "rw=${services.jellyseerr.ip}"
                "rw=${services.devbox.ip}"
                DEFAULT_NFS_SETTINGS
              ];
            };
          };

          service_radarr = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/services/radarr";
            options = {
              recordsize = "16K";
              sharenfs = builtins.concatStringsSep "," [
                "rw=${services.radarr.ip}"
                "rw=${services.devbox.ip}"
                DEFAULT_NFS_SETTINGS
              ];
            };
          };

          service_sonarr = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/services/sonarr";
            options = {
              recordsize = "16K";
              sharenfs = builtins.concatStringsSep "," [
                "rw=${services.sonarr.ip}"
                "rw=${services.devbox.ip}"
                DEFAULT_NFS_SETTINGS
              ];
            };
          };

          service_bazarr = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/services/bazarr";
            options = {
              recordsize = "16K";
              sharenfs = builtins.concatStringsSep "," [
                "rw=${services.bazarr.ip}"
                "rw=${services.devbox.ip}"
                DEFAULT_NFS_SETTINGS
              ];
            };
          };

          service_prowlarr = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/services/prowlarr";
            options = {
              recordsize = "16K";
              sharenfs = builtins.concatStringsSep "," [
                "rw=${services.prowlarr.ip}"
                "rw=${services.devbox.ip}"
                DEFAULT_NFS_SETTINGS
              ];
            };
          };

          service_qbittorrent = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/services/qbittorrent";
            options = {
              recordsize = "16K";
              sharenfs = builtins.concatStringsSep "," [
                "rw=${services.qbittorrent.ip}"
                "rw=${services.devbox.ip}"
                DEFAULT_NFS_SETTINGS
              ];
            };
          };

          service_filebrowser = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/services/filebrowser";
            options = {
              recordsize = "16K";
            };
          };

          service_vikunja = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/services/vikunja";
            options = {
              recordsize = "16K";
              sharenfs = builtins.concatStringsSep "," [
                "rw=${services.vikunja.ip}"
                "rw=${services.devbox.ip}"
                DEFAULT_NFS_SETTINGS
              ];
            };
          };

          service_paperless = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/services/paperless";
            options = {
              sharenfs = builtins.concatStringsSep "," [
                "rw=${services.paperless.ip}"
                "rw=${services.devbox.ip}"
                DEFAULT_NFS_SETTINGS
              ];
            };
          };
        };
      };
    };
  };
}
