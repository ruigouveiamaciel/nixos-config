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

        environment = {
          systemPackages = with pkgs; [wl-clipboard];
          plasma6.excludePackages = with pkgs.kdePackages; [
            kate
            spectacle
            kwallet
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
  );
}
