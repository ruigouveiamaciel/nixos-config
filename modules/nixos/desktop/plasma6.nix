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
        # Declarative printer queue, but tolerant of the printer being
        # offline (unlike hardware.printers.ensurePrinters, which fails
        # the whole unit): if the B225 can't be reached right now, this
        # is a no-op and simply runs again on the next boot/switch.
        systemd.services.cups-ensure-xerox = {
          description = "Configure Xerox B225 CUPS printer queue";
          wantedBy = ["multi-user.target"];
          wants = ["cups.service" "network-online.target"];
          after = ["cups.service" "network-online.target"];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = ''
            set +e
            ${pkgs.cups}/bin/lpadmin \
              -p Xerox-B225 -E \
              -v ipp://10.0.150.42/ipp/print \
              -m everywhere \
              -L '10.0.150.42' \
              -D 'Xerox B225 (monochrome, duplex)' \
              -o print-color-mode=monochrome \
              -o Duplex=DuplexNoTumble
            # Printer offline? Fine, try again next boot/switch.
            exit 0
          '';
        };

        # KDE recreates ~/Projects at session start (KIO places entry);
        # delete it shortly after plasmashell comes up. Only runs in
        # Plasma sessions since plasma-plasmashell.service is Plasma-specific.
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
