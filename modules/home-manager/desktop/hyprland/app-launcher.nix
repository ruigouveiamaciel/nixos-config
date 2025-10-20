{
  programs.wofi.enable = true;

  wayland.windowManager.hyprland.settings = {
    bind = [
      "$modifier, SPACE, exec, wofi --show drun"
    ];
  };
}
