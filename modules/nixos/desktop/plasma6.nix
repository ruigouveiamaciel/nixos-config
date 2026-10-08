{
  pkgs,
  lib,
  options,
  inputs,
  ...
}: let
  clipboardPkg = pkgs.wl-clipboard;
in {
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
            wayland = {
              enable = true;
              compositor = "kwin";
            };
          };
        };

        xdg.portal.enable = true;

        environment = {
          systemPackages = [
            clipboardPkg
            pkgs.kdePackages.plasma-keyboard
          ];
        };
      }
    ]
    ++ (lib.optional (options ? "home-manager") {
      home-manager.sharedModules = [
        inputs.plasma-manager.homeModules.plasma-manager
        ({
          lib,
          options,
          ...
        }: {
          config = lib.mkMerge ([
              {
                programs.fish.shellAliases = {
                  "copy" = lib.getExe' clipboardPkg "wl-copy";
                  "paste" = lib.getExe' clipboardPkg "wl-paste";
                };
              }
            ]
            ++ (
              lib.optional (options.home ? "persistence") {
                home.persistence."/persist" = {
                  directories = [
                    {
                      directory = ".local/share/flatpak/db";
                      mode = "700";
                    }
                  ];
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
            ));
        })
      ];
    })
  );
}
