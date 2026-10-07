{
  inputs,
  myModulesPath,
  lib,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.default

    "${myModulesPath}/system/impermanence.nix"
  ];

  services.fstrim.enable = true;
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
  };

  disko.devices = {
    disk.main-nvme = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-WD_BLACK_SN770M_500GB_26025T800272";
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
              mountOptions = ["umask=0077"];
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              settings = {
                allowDiscards = true;
              };
              content = {
                type = "btrfs";
                extraArgs = ["-f"];

                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "/root-blank" = {};
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "/persist" = {
                    mountpoint = "/persist";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                };

                # Snapshot the pristine @root subvolume to @root-blank,
                # so that boot can roll back to it every time
                # postCreateHook = ''
                #   MNTPOINT=$(mktemp -d)
                #   mount -t btrfs -o subvol=/ "$device" "$MNTPOINT"
                #   trap 'umount "$MNTPOINT"; rm -rf "$MNTPOINT"' EXIT
                #   btrfs subvolume snapshot "$MNTPOINT/@root" "$MNTPOINT/@root-blank"
                # '';
              };
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
  };

  fileSystems."/persist".neededForBoot = true;

  boot.initrd.systemd.services.rollback-root = {
    description = "Rollback root Btrfs subvolume";

    wantedBy = ["initrd.target"];

    after = [
      "cryptroot.target"
    ];

    before = [
      "initrd-root-fs.target"
    ];

    unitConfig = {
      DefaultDependencies = false;
    };

    serviceConfig = {
      Type = "oneshot";
    };

    script = ''
      set -e

      mkdir -p /mnt
      echo "Rollback running" > /mnt/rollback.log

      mount -t btrfs /dev/mapper/cryptroot /mnt

      # Recursively delete all nested subvolumes inside /mnt/root
      btrfs subvolume list -o /mnt/root |
        cut -f9 -d' ' |
        while read -r subvolume; do
          echo "Deleting /$subvolume subvolume..." >> /mnt/rollback.log
          btrfs subvolume delete "/mnt/$subvolume"
        done

      echo "Deleting /root subvolume..." >> /mnt/rollback.log
      btrfs subvolume delete /mnt/root

      echo "Restoring blank /root subvolume..." >> /mnt/rollback.log
      btrfs subvolume snapshot /mnt/root-blank /mnt/root

      umount /mnt
    '';
  };

  # boot.initrd.postDeviceCommands = lib.mkAfter ''
  #   echo "Rollback running" > /mnt/rollback.log
  #   mkdir -p /mnt
  #   mount -t btrfs /dev/mapper/cryptroot /mnt
  #
  #   # Recursively delete all nested subvolumes inside /mnt/root
  #   btrfs subvolume list -o /mnt/root | cut -f9 -d' ' | while read subvolume; do
  #     echo "Deleting /$subvolume subvolume..." >> /mnt/rollback.log
  #     btrfs subvolume delete "/mnt/$subvolume"
  #   done
  #
  #   echo "Deleting /root subvolume..." >> /mnt/rollback.log
  #   btrfs subvolume delete /mnt/root
  #
  #   echo "Restoring blank /root subvolume..." >> /mnt/rollback.log
  #   btrfs subvolume snapshot /mnt/root-blank /mnt/root
  #
  #   umount /mnt
  # '';

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      {
        directory = "/var/log";
        user = "root";
        group = "root";
        mode = "0755";
      }
      {
        directory = "/var/lib/bluetooth";
        user = "root";
        group = "root";
        mode = "0700";
      }
      {
        directory = "/var/lib/nixos";
        user = "root";
        group = "root";
        mode = "0755";
      }
      {
        directory = "/var/lib/systemd/coredump";
        user = "root";
        group = "root";
        mode = "0755";
      }
    ];
    files = [
      {
        file = "/etc/machine-id";
        parentDirectory = {
          user = "root";
          group = "root";
          mode = "0755";
        };
      }
    ];
  };
}
