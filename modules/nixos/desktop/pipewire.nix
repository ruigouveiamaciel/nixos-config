{
  lib,
  options,
  ...
}: {
  config = lib.mkMerge (
    [
      {
        services.pipewire = {
          enable = true;
          alsa = {
            enable = true;
            support32Bit = true;
          };
          pulse.enable = true;
          jack.enable = true;
        };
      }
    ]
    ++ (lib.optional (options ? "home-manager") {
      home-manager.sharedModules = [
        ({options, ...}: {
          config = lib.mkMerge (lib.optional (options.home ? "persistence") {
            home.persistence."/persist" = {
              directories = [
                ".local/state/wireplumber"
              ];
            };
          });
        })
      ];
    })
  );
}
