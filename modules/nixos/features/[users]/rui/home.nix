{
  inputs,
  outputs,
  pkgs,
  ...
}: {
  imports = [
    outputs.homeManagerModules.default
    outputs.homeManagerModules.constants
    inputs.impermanence.nixosModules.home-manager.impermanence
  ];

  programs.fish.shellAbbrs = {
    "rebuild" = "cd /persist/nixos-config && sudo nixos-rebuild switch --flake .#personal-gaming-desktop";
    "root-diff" = "zfs diff zroot/encrypted/root@blank";
  };

  home.packages = with pkgs; [
    kitty
    vesktop
    discord
    spotify
    hyprland-qt-support
  ];

  programs.firefox = {
    enable = true;
    package = pkgs.librewolf;
  };

  myHomeManager = {
    profiles = {
      essentials.enable = true;
      development.enable = true;
    };

    desktop.hyprland.enable = true;
  };

  home = {
    username = "rui";
    homeDirectory = "/home/rui";
  };

  wayland.windowManager.hyprland = {
    settings = {
      env = [
        "AQ_DRM_DEVICES, /dev/dri/card1"
      ];
      monitor = [
        "DP-2, 3440x1440@159.96, 0x0, 1"
        "HDMI-A-1, 1920x1080@144.00, 760x-1080, 1"
      ];
      workspace = [
        "1, monitor:DP-2, persistent:true, default:true"
        "2, monitor:DP-2, persistent:true"
        "3, monitor:DP-2, persistent:true"
        "4, monitor:DP-2, persistent:true"
        "5, monitor:DP-2, persistent:true"
        "6, monitor:HDMI-A-1, persistent:true, default:true"
        "7, monitor:HDMI-A-1, persistent:true"
        "8, monitor:HDMI-A-1, persistent:true"
        "9, monitor:HDMI-A-1, persistent:true"
        "10, monitor:HDMI-A-1, persistent:true"
      ];
      exec-once = [
        "steam"
      ];
    };
  };

  home.persistence = {
    "/persist" = {
      directories = [
        ".steam"
        ".local/share/Steam"
        ".factorio"
        ".config/spotify"
        ".config/vesktop"
        ".librewolf"
        "repos"
        ".ssh"
      ];
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}
