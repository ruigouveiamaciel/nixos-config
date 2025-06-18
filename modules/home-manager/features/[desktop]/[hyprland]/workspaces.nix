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
          "$modifier,F1,workspace,1"
          "$modifier,F2,workspace,2"
          "$modifier,F3,workspace,3"
          "$modifier,F4,workspace,4"
          "$modifier,F5,workspace,5"
          "$modifier,F6,workspace,6"
          "$modifier,F7,workspace,7"
          "$modifier,F8,workspace,8"
          "$modifier,F9,workspace,9"
          "$modifier,F10,workspace,10"

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
          "$modifier SHIFT,F1,hy3:movetoworkspace,1,follow"
          "$modifier SHIFT,F2,hy3:movetoworkspace,2,follow"
          "$modifier SHIFT,F3,hy3:movetoworkspace,3,follow"
          "$modifier SHIFT,F4,hy3:movetoworkspace,4,follow"
          "$modifier SHIFT,F5,hy3:movetoworkspace,5,follow"
          "$modifier SHIFT,F6,hy3:movetoworkspace,6,follow"
          "$modifier SHIFT,F7,hy3:movetoworkspace,7,follow"
          "$modifier SHIFT,F8,hy3:movetoworkspace,8,follow"
          "$modifier SHIFT,F9,hy3:movetoworkspace,9,follow"
          "$modifier SHIFT,F10,hy3:movetoworkspace,10,follow"
        ];
        windowrule = [
          "workspace 1, content:game"

          "workspace 1, class:factorio"
          "fullscreen, class:factorio"
          "workspace 1, class:steam_app_548430"
          "fullscreen, class:steam_app_548430"
          "workspace 1, class:steam_app_1943950"
          "fullscreen, class:steam_app_1943950"

          "workspace 2, class:kitty"

          "workspace 3, class:steam"

          "workspace 4, class:librewolf"

          "workspace 6, class:vesktop"

          "workspace 7, class:Spotify"
        ];
        workspace = [
          "1, monitor:$display1, persistent:true, default:true"
          "2, monitor:$display1, persistent:true"
          "3, monitor:$display1, persistent:true"
          "4, monitor:$display1, persistent:true"
          "5, monitor:$display1, persistent:true"
          "6, monitor:$display2, persistent:true"
          "7, monitor:$display2, persistent:true"
          "8, monitor:$display2, persistent:true"
          "9, monitor:$display2, persistent:true"
          "10, monitor:$display2, persistent:true"
        ];
      };
    };
  };
}
