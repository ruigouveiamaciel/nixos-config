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
          desktopManager.plasma6.enable = true;
          displayManager.sddm = {
            enable = true;
            wayland.enable = true;
          };
        };

        xdg.portal.enable = true;

        environment = {
          systemPackages = with pkgs; [wl-clipboard];
          plasma6.excludePackages = with pkgs.kdePackages; [
            kate
            kmenuedit
            elisa
            khelpcenter
          ];
        };
      }
    ]
    ++ (lib.optional (options ? "home-manager") {
      home-manager.sharedModules = [
        inputs.plasma-manager.homeModules.plasma-manager
      ];
    })
    ++ (lib.optional (options ? "home-manager") {
      home-manager.sharedModules = [
        ({options, ...}: {
          config = lib.mkMerge (lib.optional (options.home ? "persistence") {
            home.persistence."/persist" = {
              directories = [
                {directory = ".local/share/kwalletd"; mode = "0700";}
              ];
              files = [
                {file = ".config/kwalletrc"; parentDirectory = {mode = "0700";};}
              ];
            };
          });
        })
      ];
    })
  );
}
