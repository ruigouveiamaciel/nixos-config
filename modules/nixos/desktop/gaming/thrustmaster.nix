{
  config,
  pkgs,
  lib,
  options,
  ...
}: {
  config = lib.mkMerge (
    [
      {
        environment.systemPackages = with pkgs; [oversteer];

        boot.extraModulePackages = with config.boot.kernelPackages; [hid-tmff2];
        boot.blacklistedKernelModules = ["hid_thrustmaster"];

        services.udev = {
          enable = true;
          # https://github.com/berarma/oversteer/blob/master/data/udev/99-thrustmaster-wheel-perms.rules
          extraRules = ''
            # Match kernel name of device, rather than ATTRS{idProduct} and ATTRS{idVendor}
            # so we can access the range file and leds directory. Set rw access to these
            # files for everyone.
            # Avoid blanket matching all Thrustmaster devices, as that causes issues with mice,
            # keyboards, and other non-wheel devices.

            ACTION!="unbind", ACTION!="remove", SUBSYSTEM=="hid", ATTRS{idVendor}=="044f", GOTO="thrustmaster-rules"
            GOTO="end"

            LABEL="thrustmaster-rules"

            DRIVER=="tmff2", GOTO="tmff-new"
            DRIVER=="hid-tmff-new", GOTO="tmff-new"
            DRIVER=="hid-t150", GOTO="t150"

            GOTO="end"

            LABEL="tmff-new"

            # Thrustmaster T300RS Racing Wheel (USB)
            ATTRS{idProduct}=="b66e", RUN+="/bin/sh -c 'cd %S%p; chmod 666 range gain spring_level damper_level friction_level alternate_modes'"

            # Thrustmaster Ferrari F1 Wheel Advanced T300 (USB)
            ATTRS{idProduct}=="b66f", RUN+="/bin/sh -c 'cd %S%p; chmod 666 range gain spring_level damper_level friction_level alternate_modes'"

            # Thrustmaster T300RS GT Racing Wheel (USB)
            ATTRS{idProduct}=="b66d", RUN+="/bin/sh -c 'cd %S%p; chmod 666 range gain spring_level damper_level friction_level alternate_modes'"

            # Thrustmaster T248 Racing Wheel (USB)
            ATTRS{idProduct}=="b696", RUN+="/bin/sh -c 'cd %S%p; chmod 666 range gain spring_level damper_level friction_level'"

            # Thrustmaster TS-XW Racing Wheel (USB)
            ATTRS{idProduct}=="b692", RUN+="/bin/sh -c 'cd %S%p; chmod 666 range gain spring_level damper_level friction_level'"

            # Thrustmaster TS-PC Racing Wheel (USB)
            ATTRS{idProduct}=="b689", RUN+="/bin/sh -c 'cd %S%p; chmod 666 range gain spring_level damper_level friction_level'"

            # Thrustmaster T500RS Racing Wheel (USB)
            ATTRS{idProduct}=="b65e", RUN+="/bin/sh -c 'cd %S%p; chmod 666 range gain spring_level damper_level friction_level'"

            # Thrustmaster TX 458 Italia
            ATTRS{idProduct}=="b669", RUN+="/bin/sh -c 'cd %S%p; chmod 666 range gain spring_level damper_level friction_level'"

            GOTO="end"

            LABEL="t150"

            # Thrustmaster T150 Racing Wheel (USB)
            ATTRS{idProduct}=="b677", RUN+="/bin/sh -c 'cd %S%p; chmod 666 range gain autocenter'"

            # Thrustmaster TMX Racing Wheel (USB)
            ATTRS{idProduct}=="b67f", RUN+="/bin/sh -c 'cd %S%p; chmod 666 range gain autocenter'"

            LABEL="end"
          '';
        };
      }
    ]
    ++ (lib.optional (options ? "home-manager") {
      home-manager.sharedModules = [
        ({options, ...}: {
          config = lib.mkMerge (lib.optional (options.home ? "persistence") {
            home.persistence."/persist" = {
              directories = [
                {
                  directory = ".config/oversteer";
                  mode = "0700";
                }
              ];
            };
          });
        })
      ];
    })
  );
}
