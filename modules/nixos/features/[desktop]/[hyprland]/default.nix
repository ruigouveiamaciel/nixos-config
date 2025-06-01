_: {
  config = {
    myNixOS = {
      desktop.pipewire.enable = true;
    };

    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };
  };
}
