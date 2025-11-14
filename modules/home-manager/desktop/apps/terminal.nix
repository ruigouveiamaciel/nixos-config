{pkgs, ...}: {
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;
    shellIntegration.enableFishIntegration = true;
  };

  wayland.windowManager.hyprland.settings = {
    bind = [
      "$modifier, g, exec, kitty"
    ];
  };
}
