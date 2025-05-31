{
  outputs,
  pkgs,
  ...
}: {
  imports = [
    outputs.homeManagerModules.default
    outputs.homeManagerModules.constants
  ];

  home.packages = with pkgs; [
    firefox
    kitty
    vesktop
    hyprland-qt-support
    libnotify
    dmenu
    fd
    spotify
  ];

  myHomeManager = {
    profiles = {
      essentials.enable = true;
      development.enable = true;
    };
  };

  home = {
    username = "rui";
    homeDirectory = "/home/rui";
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;

    settings = {
      "$mod" = "SUPER";
      "$winMod" = "SUPER";
      bindm = [
        "$winMod, mouse:272, movewindow"
        "$winMod, mouse:273, resizewindow"
      ];

      bind = [
        "SUPER, T, exec, kitty"
        "SUPER, W, killactive,"
        "SUPER, SPACE, exec, wofi --show drun"

        "$winMod SHIFT,F,togglefloating,"
        "$winMod SHIFT,left,movewindow,l"
        "$winMod SHIFT,right,movewindow,r"
        "$winMod SHIFT,up,movewindow,u"
        "$winMod SHIFT,down,movewindow,d"
        "$winMod SHIFT,h,movewindow,l"
        "$winMod SHIFT,l,movewindow,r"
        "$winMod SHIFT,k,movewindow,u"
        "$winMod SHIFT,j,movewindow,d"

        "$winMod,left,movefocus,l"
        "$winMod,right,movefocus,r"
        "$winMod,up,movefocus,u"
        "$winMod,down,movefocus,d"
        "$winMod,h,movefocus,l"
        "$winMod,l,movefocus,r"
        "$winMod,k,movefocus,u"
        "$winMod,j,movefocus,d"
        "$winMod,1,workspace,1"
        "$winMod,2,workspace,2"
        "$winMod,3,workspace,3"
        "$winMod,4,workspace,4"
        "$winMod,5,workspace,5"
        "$winMod,6,workspace,6"
        "$winMod,7,workspace,7"
        "$winMod,8,workspace,8"
        "$winMod,9,workspace,9"
        "$winMod,0,workspace,10"

        "$winMod, P,togglespecialworkspace"
        "$winMod SHIFT,1,movetoworkspace,1"
        "$winMod SHIFT,2,movetoworkspace,2"
        "$winMod SHIFT,3,movetoworkspace,3"
        "$winMod SHIFT,4,movetoworkspace,4"
        "$winMod SHIFT,5,movetoworkspace,5"
        "$winMod SHIFT,6,movetoworkspace,6"
        "$winMod SHIFT,7,movetoworkspace,7"
        "$winMod SHIFT,8,movetoworkspace,8"
        "$winMod SHIFT,9,movetoworkspace,9"
        "$winMod SHIFT,0,movetoworkspace,10"

        "ALT,Tab,cyclenext"
        "ALT,Tab,bringactivetotop"
        ",XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        " ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioPlay, exec, playerctl play-pause"
        ",XF86AudioPause, exec, playerctl play-pause"
        ",XF86AudioNext, exec, playerctl next"
        ",XF86AudioPrev, exec, playerctl previous"
        ",XF86MonBrightnessDown,exec,brightnessctl set 5%-"
        ",XF86MonBrightnessUp,exec,brightnessctl set +5%"
      ];
      general = {
        border_size = 2;
        no_border_on_floating = false;
        gaps_in = 8;
        gaps_out = 16;
        gaps_workspaces = 0;
        layout = "dwindle";
        resize_on_border = true;
        extend_border_grab_area = 8;
      };
      decoration = {
        rounding = 8;
        border_part_of_window = false;
        dim_inactive = false;
        blur = {
          enabled = false;
        };
        shadow = {
          enabled = true;
        };
      };
      animations = {
        enabled = false;
      };
      input = {
        kb_model = "pc104";
        kb_layout = "pt";
        repeat_rate = 25;
        repeat_delay = 600;

        sensitivity = 0.0;
        accel_profile = "flat";
        scroll_method = "2fg";
        scroll_factor = 1.0;
        natural_scroll = false;
        follow_mouse = 2;

        touchpad = {
          disable_while_typing = false;
          natural_scroll = true;
          tap-to-click = true;
        };
      };
      gestures = {
        workspace_swipe = false;
      };
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        vrr = 3;
        middle_click_paste = false;
      };
      ecosystem = {
        no_update_news = true;
        no_donation_nag = true;
      };
      xwayland = {
        force_zero_scaling = true;
      };
      monitor = [
        "DP-2, 3440x1440@159.96, 0x0, 1"
        "HDMI-A-1, 1920x1080@144.00, 760x-1080, 1"
      ];
      env = [
        "AQ_DRM_DEVICES, /dev/dri/card0:/dev/dri/card1"
        "INSTALL_QML_PREFIX, org.hyprland.style"
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
    };
  };

  services = {
    hyprpolkitagent.enable = true;
    dunst.enable = true;
  };

  programs.wofi.enable = true;

  # TODO: Music player in terminal
  # TODO: Neovim dashboard
  # TODO: OSD using dunst
  # TODO: Shortcuts in Hyprland
  # TODO: Notification center to see notification history
  # TODO: Lock screen
  # TODO: Wallpaper
  # TODO: Stylix
  # TODO: Setup impermanence
  # TODO: Setup waterfox
  # TODO: Setup workspaces for multi monitor
  # TODO: Figure out special workspace
  # TODO: Fix steam
  # TODO: Make window manager more like i3
  # TODO: Better user module

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}
