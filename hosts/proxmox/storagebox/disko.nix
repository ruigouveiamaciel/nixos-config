{
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
        };
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
            };
          };

          media_movies = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/media/movies";
            options = {
              recordsize = "1M";
              logbias = "throughput";
              "com.sun:auto-snapshot" = "false";
            };
          };

          media_tvshows = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/media/tvshows";
            options = {
              recordsize = "1M";
              logbias = "throughput";
              "com.sun:auto-snapshot" = "false";
            };
          };

          media_anime = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/media/anime";
            options = {
              recordsize = "1M";
              logbias = "throughput";
              "com.sun:auto-snapshot" = "false";
            };
          };
        };
      };
    };
  };
}
