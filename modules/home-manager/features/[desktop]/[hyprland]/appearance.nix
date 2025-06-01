_: {
  config = {
    wayland.windowManager.hyprland = {
      settings = {
        general = {
          border_size = 2;
          no_border_on_floating = false;
          gaps_in = 8;
          gaps_out = 16;
          gaps_workspaces = 0;
        };
        decoration = {
          rounding = 8;
          border_part_of_window = false;
          dim_inactive = false;
          blur.enabled = false;
          shadow.enabled = true;
        };
        animations.enabled = false;
        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
        };
        ecosystem = {
          no_update_news = true;
          no_donation_nag = true;
        };
        xwayland = {
          force_zero_scaling = true;
        };
      };
    };
  };
}
