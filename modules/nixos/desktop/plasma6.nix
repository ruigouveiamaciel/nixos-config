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
        systemd.user.services.remove-kde-projects-dir = {
          description = "Remove the ~/Projects folder KDE keeps recreating";
          after = ["plasma-plasmashell.service"];
          wantedBy = ["plasma-plasmashell.service"];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = ''${pkgs.runtimeShell} -c 'sleep 5; rm -rf -- "$HOME/Projects"' '';
          };
        };

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
            (pkgs.writeShellApplication {
              name = "setup-xerox-b225";
              runtimeInputs = [pkgs.coreutils];
              text = ''
                lpstat=${lib.getExe' pkgs.cups "lpstat"}
                lpadmin=${lib.getExe' pkgs.cups "lpadmin"}
                systemctl=${lib.getExe' pkgs.systemd "systemctl"}

                if ! "$lpstat" -p Xerox-B225 >/dev/null 2>&1; then
                  sudo "$systemctl" start cups.service
                  "$lpadmin" \
                    -p Xerox-B225 -E \
                    -v ipp://10.0.150.42/ipp/print \
                    -m everywhere \
                    -L '10.0.150.42' \
                    -D 'Xerox B225 (monochrome, duplex)' \
                    -o print-color-mode=monochrome \
                    -o Duplex=DuplexNoTumble
                fi
              '';
            })
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
                home.packages = [
                  (pkgs.writeShellApplication {
                    name = "copy";
                    text = ''${lib.getExe' clipboardPkg "wl-copy"} "$@"'';
                  })
                  (pkgs.writeShellApplication {
                    name = "paste";
                    text = ''${lib.getExe' clipboardPkg "wl-paste"} "$@"'';
                  })
                ];
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
