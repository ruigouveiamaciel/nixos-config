_: {
  config = {
    wayland.windowManager.hyprland = {
      settings = {
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
          middle_click_paste = false;
        };
      };
    };
  };
}
