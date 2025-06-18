_: {
  config = {
    myNixOS = {
      desktop = {
        pipewire.enable = true;

        hyprland = {
          hyprlock.enable = true;
        };
      };
    };

    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };
  };
}
