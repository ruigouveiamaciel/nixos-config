{
  imports = [../minimal-vm/disko.nix];

  boot.supportedFilesystems = ["zfs"];

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
      zdata1 = {
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
            cache = [];
          };
        };
        rootFsOptions = {
          compression = "zstd";
          xattr = "sa";
          atime = "off";
          "com.sun:auto-snapshot" = "true";
        };
        mountpoint = "/mnt/zdata1";
        datasets = {
          media = {
            type = "zfs_fs";
            mountpoint = "/media";
            options = {
              recordsize = "1M";
              "com.sun:auto-snapshot" = "false";
            };
          };
          personal_media = {
            type = "zfs_fs";
            mountpoint = "/media/personal";
            options = {
              recordsize = "1M";
              "com.sun:auto-snapshot" = "true";
            };
          };
        };
      };
    };
  };
}
