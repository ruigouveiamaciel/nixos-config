{
  disko.devices = {
    disk = {
      nvme1 = {
        device = "/dev/nvme0n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02";
            };
            ESP = {
              type = "EF00";
              size = "500M";
              content = {
                type = "mdraid";
                name = "boot";
              };
            };
            nixos = {
              size = "100%";
              content = {
                type = "mdraid";
                name = "nixos";
              };
            };
            swap = {
              size = "16G";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            };
          };
        };
      };
      nvme2 = {
        device = "/dev/nvme1n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02";
            };
            ESP = {
              type = "EF00";
              size = "500M";
              content = {
                type = "mdraid";
                name = "boot";
              };
            };
            nixos = {
              size = "100%";
              content = {
                type = "mdraid";
                name = "nixos";
              };
            };
            swap = {
              size = "16G";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            };
          };
        };
      };
    };
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = ["mode=0755" "size=16G"];
      };
    };
    mdadm = {
      boot = {
        type = "mdadm";
        level = 1;
        metadata = "1.0";
        content = {
          type = "filesystem";
          format = "vfat";
          mountpoint = "/boot";
          mountOptions = ["umask=0077" "defaults"];
        };
      };
      nixos = {
        type = "mdadm";
        level = 0;
        content = {
          type = "gpt";
          partitions = {
            nix = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/nix";
              };
            };
          };
        };
      };
    };
  };
}
