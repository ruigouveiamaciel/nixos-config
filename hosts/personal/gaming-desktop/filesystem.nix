{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.default
    inputs.impermanence.nixosModules.impermanence
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
    disk.main-nvme = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_2TB_S7HENJ0Y236219V";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            name = "nixos-boot";
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          zfs = {
            name = "nixos";
            size = "100%";
            content = {
              type = "zfs";
              pool = "zroot";
            };
          };
          swap = {
            name = "linux-swap";
            size = "32G";
            content = {
              type = "swap";
              randomEncryption = true;
            };
          };
        };
      };
    };
    zpool.zroot = {
      type = "zpool";
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
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
    ];
  };
}
