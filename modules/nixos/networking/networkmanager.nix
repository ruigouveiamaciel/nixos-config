{
  options,
  lib,
  ...
}: {
  config = lib.mkMerge ([
      {
        networking.networkmanager = {
          enable = true;
          wifi.backend = "iwd";
        };
      }
    ]
    ++ (lib.optional (options.environment ? "persistence") {
      environment.persistence."/persist" = {
        directories = [
          {
            directory = "/etc/NetworkManager/system-connections";
            user = "root";
            group = "root";
            mode = "0700";
          }
          {
            directory = "/var/lib/iwd";
            user = "root";
            group = "root";
            mode = "0700";
          }
        ];
      };
    }));
}
