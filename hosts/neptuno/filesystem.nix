{
  inputs,
  myModulesPath,
  config,
  pkgs,
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
    fileSystems = ["/persist"];
  };

  disko.devices = {
    # TODO: replace with the actual NVMe disk of this machine
    # (ls /dev/disk/by-id/ | grep -v -E 'part|wwn')
    disk.main-nvme = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-FRAMEWORK_NVMe_-XXXX_XXXX_XXXX_XXXX";
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
            name = "nixos-crypt";
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
                  "@root" = {
                    mountpoint = "/";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "@root-blank" = {};
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "@persist" = {
                    mountpoint = "/persist";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                };

                # Snapshot the pristine @root subvolume to @root-blank,
                # so that boot can roll back to it every time
                postCreateHook = ''
                  MNTPOINT=$(mktemp -d)
                  mount -t btrfs -o subvol=/ "$device" "$MNTPOINT"
                  trap 'umount "$MNTPOINT"; rm -rf "$MNTPOINT"' EXIT
                  btrfs subvolume snapshot "$MNTPOINT/@root" "$MNTPOINT/@root-blank"
                '';
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

  boot.initrd.systemd = {
    enable = true;
    services.rollback = {
      description = "Rollback @root subvolume to its blank state";
      wantedBy = ["initrd.target"];
      after = ["systemd-cryptsetup@cryptroot.service"];
      before = ["sysroot.mount"];
      path = [pkgs.btrfs-progs];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        MNTPOINT=$(mktemp -d)
        mount -t btrfs -o subvol=/ /dev/mapper/cryptroot "$MNTPOINT"

        if [ -e "$MNTPOINT/@root-blank" ]; then
          if btrfs subvolume show "$MNTPOINT/@root" > /dev/null 2>&1; then
            btrfs subvolume delete "$MNTPOINT/@root"
          fi
          btrfs subvolume snapshot "$MNTPOINT/@root-blank" "$MNTPOINT/@root"
        fi

        umount "$MNTPOINT"
        rm -rf "$MNTPOINT"
      '';
    };
  };

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
