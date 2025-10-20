{myModulesPath, ...}: {
  imports = [
    "${myModulesPath}/desktop/hyprland"
    "${myModulesPath}/desktop/applications"
    "${myModulesPath}/desktop/gaming"
  ];

  programs.fish.shellAbbrs = {
    "rebuild" = "cd /persist/nixos-config && sudo nixos-rebuild switch --flake .#personal-gaming-desktop";
    "root-diff" = "sudo zfs diff zroot/encrypted/root@blank";
  };

  wayland.windowManager.hyprland = {
    settings = {
      "$display1" = "DP-2";
      "$display2" = "HDMI-A-1";
      env = [
        "AQ_DRM_DEVICES, /dev/dri/card1"
      ];
      monitor = [
        "$display1, 3440x1440@159.96, 0x0, 1"
        "$display2, 1920x1080@120, 760x-1080, 1"
      ];
    };
  };
}
