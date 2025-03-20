{config, ...}: let
  services = config.myNixOS.services.discovery.default;
in {
  imports = [../minimal-vm/disko.nix];

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
          canmount = "noauto";
          atime = "off";
          aclinherit = "passthrough";
          aclmode = "restricted";
          "com.sun:auto-snapshot" = "true"; # By default, snapshot everything
          sharenfs = "off"; # By default, do not share on nfs
        };
        postCreateHook = ''
          chmod -R 755 ${ROOT_MOUNTPOINT}
          chown -R nobody:nogroup ${ROOT_MOUNTPOINT}
        '';
        mountpoint = ROOT_MOUNTPOINT;
        datasets = {
          downloads = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/downloads";
            options = {
              compression = "off";
              recordsize = "16k"; # Torrenting is not sequential
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
              sharenfs = builtins.concatStringsSep "," [
                "rw=${services.radarr.ip}"
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
