{pkgs, ...}: {
  config = {
    wayland.windowManager.hyprland = {
      plugins = with pkgs.hyprlandPlugins; [hy3];
      settings = {
        bindm = [
          "$modifier, mouse:272, movewindow"
          "$modifier, mouse:273, resizewindow"
        ];
        general = {
          layout = "hy3";
          resize_on_border = false;
          extend_border_grab_area = 0;
        };
        plugin = {
          hy3 = {
            no_gaps_when_only = 0; # Always show gaps
            node_collapse_policy = 0; # Always remove empty groups
            group_inset = 64; # Add an inset to groups with only one window
          };
        };
        bind = [
          "$modifier,W,hy3:killactive"
          "$modifier,code:47,hy3:makegroup,v,toggle,ephemeral"
          "$modifier,D,togglefloating"
          "$modifier,M,fullscreen"

          "$modifier,H,hy3:movefocus,left"
          "$modifier,J,hy3:movefocus,down"
          "$modifier,K,hy3:movefocus,up"
          "$modifier,L,hy3:movefocus,right"

          "$modifier SHIFT,H,hy3:movewindow,left"
          "$modifier SHIFT,J,hy3:movewindow,down"
          "$modifier SHIFT,K,hy3:movewindow,up"
          "$modifier SHIFT,L,hy3:movewindow,right"

          "$modifier,1,workspace,1"
          "$modifier,2,workspace,2"
          "$modifier,3,workspace,3"
          "$modifier,4,workspace,4"
          "$modifier,5,workspace,5"
          "$modifier,6,workspace,6"
          "$modifier,7,workspace,7"
          "$modifier,8,workspace,8"
          "$modifier,9,workspace,9"
          "$modifier,0,workspace,10"

          "$modifier SHIFT,1,hy3:movetoworkspace,1,follow"
          "$modifier SHIFT,2,hy3:movetoworkspace,2,follow"
          "$modifier SHIFT,3,hy3:movetoworkspace,3,follow"
          "$modifier SHIFT,4,hy3:movetoworkspace,4,follow"
          "$modifier SHIFT,5,hy3:movetoworkspace,5,follow"
          "$modifier SHIFT,6,hy3:movetoworkspace,6,follow"
          "$modifier SHIFT,7,hy3:movetoworkspace,7,follow"
          "$modifier SHIFT,8,hy3:movetoworkspace,8,follow"
          "$modifier SHIFT,9,hy3:movetoworkspace,9,follow"
          "$modifier SHIFT,0,hy3:movetoworkspace,10,follow"
        ];
      };
    };
  };
}
