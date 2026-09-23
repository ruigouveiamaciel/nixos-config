{
  pkgs,
  lib,
  options,
  inputs,
  ...
}: {
  imports = [
    ./pipewire.nix
  ];

  config = lib.mkMerge (
    [
      {
        services = {
          printing.enable = true;
          desktopManager.plasma6.enable = true;
          displayManager.sddm = {
            enable = true;
            wayland.enable = true;
          };
        };

        xdg.portal.enable = true;

        environment = {
          systemPackages = with pkgs; [wl-clipboard];
        };
      }
    ]
    ++ (lib.optional (options.environment ? "persistence") {
      environment.persistence."/persist" = {
        directories = [
          # {
          #   directory = "/etc/cups";
          #   user = "root";
          #   group = "root";
          #   mode = "0700";
          # }
        ];
      };
    })
    ++ (lib.optional (options ? "home-manager") {
      home-manager.sharedModules = [
        inputs.plasma-manager.homeModules.plasma-manager
        ({
          lib,
          options,
          ...
        }: {
          config = lib.mkMerge (
            lib.optional (options.home ? "persistence") {
              home.persistence."/persist" = {
                files = [
                  {
                    # Remember monitor settings
                    file = ".config/kwinoutputconfig.json";
                    parentDirectory = {
                      mode = "0700";
                    };
                  }
                ];
              };
            }
          );
        })
      ];
    })
  );
}
