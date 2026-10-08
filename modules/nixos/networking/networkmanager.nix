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
          # NM pushes its own DNS into resolved per-link, and openresolv
          # (used by wg-quick's DNS= handling) talks to resolved over D-Bus
          dns = "systemd-resolved";
        };

        services.resolved.enable = true;
      }
    ]
    ++ (lib.optional (options.environment ? "persistence") {
      environment.persistence."/persist" = {
        directories = [
          # {
          #   directory = "/etc/NetworkManager/system-connections";
          #   user = "root";
          #   group = "root";
          #   mode = "0700";
          # }
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
