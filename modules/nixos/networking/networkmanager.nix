{
  options,
  lib,
  ...
}: {
  config = lib.mkMerge ([
      {
        networking.networkmanager.enable = true;
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
        ];
      };
    }));
}
