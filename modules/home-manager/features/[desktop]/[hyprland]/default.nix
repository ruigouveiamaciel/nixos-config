{pkgs, ...}: {
  config = {
    myHomeManager.desktop = {
      stylix.enable = true;
      hyprland = {
        media-control.enable = true;
        workspaces.enable = true;
        app-launcher.enable = true;
        polkit-agent.enable = true;
        appearance.enable = true;
        input.enable = true;
        hyprpanel.enable = true;
      };
    };

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
  };
}
