{
  inputs,
  pkgs,
  myModulesPath,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.default

    "${myModulesPath}/profiles/impermanence.nix"
  ];

  boot = {
    supportedFilesystems = ["zfs"];
    zfs.devNodes = "/dev/disk/by-partlabel";
  };

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };

  disko.devices = {
    disk = {
      nvme1 = {
        device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_1TB_S6Z1NU0X554636E";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              type = "EF00";
              size = "1G";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077" "defaults"];
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
            swap = {
              size = "12G";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            };
          };
        };
      };
      nvme2 = {
        device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_1TB_S6Z1NJ0Y301003F";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
            swap = {
              size = "12G";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            };
          };
        };
      };
      nvme3 = {
        device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_2TB_S6S2NS0T215740H";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
            swap = {
              size = "12G";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            };
          };
        };
      };
    };
    mdadm = {
      boot = {
        type = "mdadm";
        level = 1;
        metadata = "1.0";
        content = {
        };
      };
    };
    zpool.zroot = {
      type = "zpool";

      mode = {
        topology = {
          type = "topology";
          vdev = [
            {
              members = ["nvme1" "nvme2" "nvme3"];
            }
          ];
        };
      };

      rootFsOptions = {
        compression = "zstd";
        mountpoint = "none";
        "com.sum:auto-snapshot" = "false";
        acltype = "posixacl";
        atime = "off";
        relatime = "on";
        xattr = "sa";
      };

      datasets = {
        encrypted = {
          type = "zfs_fs";
          options = {
            mountpoint = "none";
            encryption = "aes-256-gcm";
            keyformat = "passphrase";
            keylocation = "prompt";
          };
        };
        "encrypted/root" = {
          type = "zfs_fs";
          options.mountpoint = "legacy";
          mountpoint = "/";
          postCreateHook = "zfs snapshot zroot/encrypted/root@blank";
        };
        "encrypted/nix" = {
          type = "zfs_fs";
          options.mountpoint = "legacy";
          mountpoint = "/nix";
        };
        "encrypted/persist" = {
          type = "zfs_fs";
          options = {
            mountpoint = "legacy";
            "com.sun:auto-snapshot" = "true";
          };
          mountpoint = "/persist";
        };
      };
    };
  };

  fileSystems."/persist".neededForBoot = true;

  boot.initrd.systemd = {
    enable = true;
    services.rollback = {
      description = "Rollback root to an empty state";
      wantedBy = ["initrd.target"];
      after = [
        "zfs-import-zroot.service"
        "initrd-root-device.target"
      ];
      before = ["sysroot.mount"];
      path = with pkgs; [zfs];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        zfs rollback -r zroot/encrypted/root@blank
      '';
    };
  };

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
    ];
    files = [
      "/etc/machine-id"
    ];
  };
}
