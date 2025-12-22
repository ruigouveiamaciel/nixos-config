{pkgs, ...}: {
  services.aerospace = {
    enable = true;
    package = pkgs.unstable.aerospace;
    settings = {
      default-root-container-layout = "tiles";
      gaps = {
        outer = {
          left = 8;
          bottom = 8;
          top = 8;
          right = 8;
        };
        inner = {
          horizontal = 8;
          vertical = 8;
        };
      };
      mode = {
        main.binding = {
          alt-period = "layout tiles horizontal vertical";
          alt-comma = "layout accordion horizontal vertical";
          alt-f = "layout floating tiling";
          alt-r = "flatten-workspace-tree";

          alt-h = ["focus left" "move-mouse window-force-center"];
          alt-j = ["focus down" "move-mouse window-force-center"];
          alt-k = ["focus up" "move-mouse window-force-center"];
          alt-l = ["focus right" "move-mouse window-force-center"];

          alt-shift-h = "move left";
          alt-shift-j = "move down";
          alt-shift-k = "move up";
          alt-shift-l = "move right";

          alt-ctrl-h = "join-with left";
          alt-ctrl-j = "join-with down";
          alt-ctrl-k = "join-with up";
          alt-ctrl-l = "join-with right";

          alt-n = "resize smart -50";
          alt-p = "resize smart +50";

          cmd-1 = "workspace 1";
          cmd-2 = "workspace 2";
          cmd-3 = "workspace 3";
          cmd-4 = "workspace 4";
          cmd-5 = "workspace 5";
          cmd-6 = "workspace 6";
          cmd-7 = "workspace 7";
          cmd-8 = "workspace 8";
          cmd-9 = "workspace 9";
          cmd-0 = "workspace 10";

          cmd-shift-1 = ["move-node-to-workspace 1" "workspace 1"];
          cmd-shift-2 = ["move-node-to-workspace 2" "workspace 2"];
          cmd-shift-3 = ["move-node-to-workspace 3" "workspace 3"];
          cmd-shift-4 = ["move-node-to-workspace 4" "workspace 4"];
          cmd-shift-5 = ["move-node-to-workspace 5" "workspace 5"];
          cmd-shift-6 = ["move-node-to-workspace 6" "workspace 6"];
          cmd-shift-7 = ["move-node-to-workspace 7" "workspace 7"];
          cmd-shift-8 = ["move-node-to-workspace 8" "workspace 8"];
          cmd-shift-9 = ["move-node-to-workspace 9" "workspace 9"];
          cmd-shift-0 = ["move-node-to-workspace 10" "workspace 10"];
        };
      };

      workspace-to-monitor-force-assignment = {
        "1" = "main";
        "2" = "main";
        "3" = "main";
        "4" = "main";
        "5" = "main";
        "6" = ["secondary" "main"];
        "7" = ["secondary" "main"];
        "8" = ["secondary" "main"];
        "9" = ["secondary" "main"];
        "10" = ["secondary" "main"];
      };

      on-window-detected = [
        {
          "if".app-id = "com.microsoft.teams2";
          run = ["move-node-to-workspace 10"];
        }
        {
          "if".app-id = "com.tinyspeck.slackmacgap";
          run = ["move-node-to-workspace 10"];
        }
        {
          "if".app-id = "com.microsoft.Outlook";
          run = ["move-node-to-workspace 10"];
        }
        {
          "if".app-id = "net.waterfox.waterfox";
          run = ["move-node-to-workspace 4"];
        }
        {
          "if".app-id = "com.mitchellh.ghostty";
          run = ["move-node-to-workspace 1"];
        }
        {
          "if".app-id = "io.zsaq.keymapp";
          run = ["move-node-to-workspace 5"];
        }
        {
          "if".app-id = "com.spotify.client";
          run = ["move-node-to-workspace 5"];
        }
        {
          "if".app-id = "com.cisco.secureclient.gui";
          run = ["layout floating"];
        }
        {
          "if".app-id = "com.apple.systempreferences";
          run = ["layout floating"];
        }
      ];
    };
  };
}
