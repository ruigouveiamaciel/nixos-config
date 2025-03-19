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
      #mediadrive = {
      #  device = "/dev/sdb";
      #  type = "disk";
      #  content = {
      #    type = "gpt";
      #    partitions = {
      #      mediapart = {
      #        label = "mediapart";
      #        size = "100%";
      #        content = {
      #          type = "filesystem";
      #          format = "ext4";
      #          mountpoint = "/mnt/das";
      #        };
      #      };
      #    };
      #  };
      #};
    };

    zpool = {
      zdata1 = let
        ROOT_MOUNTPOINT = "/mnt/zdata1";
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
        rootFsOptions = {
          compression = "zstd";
          xattr = "sa";
          canmount = "noauto";
          atime = "off";
          ashift = "12";
          "com.sun:auto-snapshot" = "true";
        };
        mountpoint = ROOT_MOUNTPOINT;
        datasets = {
          media = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/media";
            options = {
              recordsize = "1M";
              "com.sun:auto-snapshot" = "false";
            };
          };
          backup = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/backup";
            options = {
              compression = "zstd-15";
              "com.sun:auto-snapshot" = "true";
            };
          };
        };
      };
    };
  };
}
