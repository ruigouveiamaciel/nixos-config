{pkgs, ...}: {
  imports = [
    ../stylix.nix

    ./app-launcher.nix
    ./appearance.nix
    ./hyprpanel.nix
    ./input.nix
    ./media-control.nix
    ./polkit-agent.nix
    ./workspaces.nix
  ];

  home.packages = with pkgs; [
    hyprland-qt-support
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
