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
    ++ (lib.optional (options ? "home-manager") {
      home-manager.sharedModules = [
        inputs.plasma-manager.homeModules.plasma-manager
      ];
    })
  );
}
