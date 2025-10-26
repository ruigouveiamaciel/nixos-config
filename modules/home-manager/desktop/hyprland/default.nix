{pkgs, ...}: {
  imports = [
    ../stylix.nix

    ./appearance.nix
    ./input.nix
    ./media-control.nix
    ./polkit-agent.nix
    ./workspaces.nix

    ./ags
  ];

  home.packages = with pkgs; [
    hyprland-qt-support
    wl-clipboard
    nautilus
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    settings = {
      "$modifier" = "SUPER";
    };
  };
}
