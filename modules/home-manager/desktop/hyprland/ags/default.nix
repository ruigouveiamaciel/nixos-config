{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.ags.homeManagerModules.default
  ];

  programs.ags = {
    enable = true;
    systemd.enable = true;
    configDir = ./config;
    extraPackages = with inputs.astal.packages.${pkgs.system}; [
      tray
      wireplumber
      apps
      pkgs.libadwaita
    ];
  };

  wayland.windowManager.hyprland.settings = {
    bind = [
      "$modifier, SPACE, exec, ags toggle application-launcher"
      "$modifier, I, exec, ags toggle microphone-selector"
      "$modifier, O, exec, ags toggle speaker-selector"
      "$modifier, T, exec, ags toggle tray"
    ];
  };
}
