{
  disko.devices = {
    disk = {
      mediadrive = {
        device = "/dev/sdb";
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
                mountpoint = "/mnt/media";
              };
            };
          };
        };
      };
    };
  };
}
