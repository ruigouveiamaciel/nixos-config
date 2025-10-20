{
  imports = [
    ../pipewire.nix

    ./hyprlock.nix
  ];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };
}
