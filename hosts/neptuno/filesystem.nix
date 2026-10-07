{
  inputs,
  myModulesPath,
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
  boot.initrd.systemd = {
    enable = true;
    services.rollback = {
      description = "Rollback root to an empty state";
      wantedBy = ["initrd.target"];
      after = [
        "initrd-root-device.target"
        "cryptsetup.target"
      ];
      before = ["sysroot.mount"];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        set -e

        mkdir -p /mnt
        mount -t btrfs /dev/mapper/cryptroot /mnt

        # Recursively delete all nested subvolumes inside /mnt/root
        btrfs subvolume list -o /mnt/root |
          cut -f9 -d' ' |
          while read -r subvolume; do
            btrfs subvolume delete "/mnt/$subvolume"
          done

        btrfs subvolume delete /mnt/root
        btrfs subvolume snapshot /mnt/root-blank /mnt/root

        umount /mnt
      '';
    };
  };
}
