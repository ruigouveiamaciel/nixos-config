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
      mediadrive = {
        device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            mediapart = {
              label = "mediapart";
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/mnt/das";
              };
            };
          };
        };
      };
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
        options = {
          ashift = "12";
        };
        rootFsOptions = {
          compression = "zstd";
          xattr = "sa";
          canmount = "noauto";
          "com.sun:auto-snapshot" = "true";
        };
        mountpoint = ROOT_MOUNTPOINT;
        datasets = {
          media = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/media";
            options = {
              recordsize = "1M";
              logbias = "throughput";
              "com.sun:auto-snapshot" = "false";
            };
          };
          personal_media = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/media/personal";
            options = {
              recordsize = "1M";
              logbias = "throughput";
              "com.sun:auto-snapshot" = "true";
            };
          };
          downloads = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/downloads";
            options = {
              compression = "off";
              recordsize = "16k";
              logbias = "throughput";
              "com.sun:auto-snapshot" = "false";
            };
          };
          services = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/services";
            options = {
              logbias = "latency";
              recordsize = "16k";
            };
          };
          services_immich_media_upload = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/services/immich/media/upload";
            options = {
              logbias = "latency";
              recordsize = "1M";
            };
          };
          services_immich_backups = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/services/immich/media/backups";
            options = {
              logbias = "throughput";
              recordsize = "1M";
              "com.sun:auto-snapshot" = "false";
            };
          };
          services_paperless_consume = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/services/paperless/consume";
            options = {
              compression = "off";
              logbias = "throughput";
              recordsize = "128K";
              "com.sun:auto-snapshot" = "false";
            };
          };
          services_paperless_media = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/services/paperless/media";
            options = {
              logbias = "latency";
              recordsize = "1M";
            };
          };
          services_paperless_export = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/services/paperless/export";
            options = {
              logbias = "throughput";
              recordsize = "1M";
              "com.sun:auto-snapshot" = "false";
            };
          };
          services_vikunja_files = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/services/vikunja/files";
            options = {
              logbias = "latency";
              recordsize = "128K";
            };
          };
          backups = {
            type = "zfs_fs";
            mountpoint = "${ROOT_MOUNTPOINT}/backups";
            options = {
              compression = "zstd-15";
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
