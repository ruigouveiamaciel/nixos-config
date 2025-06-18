_: {
  config = {
    myHomeManager.desktop.gaming = {
      minecraft.enable = true;
    };

    wayland.windowManager.hyprland.settings = {
      general = {
        allow_tearing = true;
      };
      misc = {
        vrr = 2;
      };
      exec-once = [
        "steam"
      ];
    };

    home.persistence."/persist" = {
      directories = [
        ".steam"
        ".local/share/Steam"
        ".factorio"
      ];
    };
  };
}
