{
  lib,
  pkgs,
  ...
}: {
  programs.git = {
    userEmail = lib.mkForce "rum@axogroup.com";
    userName = lib.mkForce "Rui Maciel";
  };

  home = {
    sessionPath = [
      "/Users/ruimaciel/repos/ax/out"
    ];
    sessionVariables = {
      SHELL = "${pkgs.fish}/bin/fish";
    };
  };

  programs = {
    fish = {
      shellInit = ''
        if test -n "$GHOSTTY_RESOURCES_DIR"
          . "$GHOSTTY_RESOURCES_DIR"/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish
          end
      '';
      shellAliases = {
        "rebuild" = "cd ~/repos/nixos-config && sudo darwin-rebuild switch --flake .#darwin-work";
        "ad" = "cd ~/repos/frontend/apps/ace && pnpm dev";
        "fo" = "cd ~/repos/frontend && nvim .";
        "no" = "cd ~/repos/nixos-config && nvim .";
      };
    };

    aerospace = {
      enable = true;
      package = pkgs.unstable.aerospace;
      userSettings = {
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

            alt-h = ["focus left" "move-mouse window-lazy-center"];
            alt-j = ["focus down" "move-mouse window-lazy-center"];
            alt-k = ["focus up" "move-mouse window-lazy-center"];
            alt-l = ["focus right" "move-mouse window-lazy-center"];

            alt-shift-h = "move left";
            alt-shift-j = "move down";
            alt-shift-k = "move up";
            alt-shift-l = "move right";

            alt-ctrl-h = "join-with left";
            alt-ctrl-j = "join-with down";
            alt-ctrl-k = "join-with up";
            alt-ctrl-l = "join-with right";

            alt-slash = "resize smart -50";
            alt-equal = "resize smart +50";

            alt-f1 = "workspace 1";
            alt-f2 = "workspace 2";
            alt-f3 = "workspace 3";
            alt-f4 = "workspace 4";
            alt-f5 = "workspace 5";
            alt-f6 = "workspace 6";
            alt-f7 = "workspace 7";
            alt-f8 = "workspace 8";
            alt-f9 = "workspace 9";
            alt-f10 = "workspace 10";

            alt-shift-f1 = ["move-node-to-workspace 1" "workspace 1"];
            alt-shift-f2 = ["move-node-to-workspace 2" "workspace 2"];
            alt-shift-f3 = ["move-node-to-workspace 3" "workspace 3"];
            alt-shift-f4 = ["move-node-to-workspace 4" "workspace 4"];
            alt-shift-f5 = ["move-node-to-workspace 5" "workspace 5"];
            alt-shift-f6 = ["move-node-to-workspace 6" "workspace 6"];
            alt-shift-f7 = ["move-node-to-workspace 7" "workspace 7"];
            alt-shift-f8 = ["move-node-to-workspace 8" "workspace 8"];
            alt-shift-f9 = ["move-node-to-workspace 9" "workspace 9"];
            alt-shift-f10 = ["move-node-to-workspace 10" "workspace 10"];

            cmd-h = "move-mouse window-lazy-center";
            alt-f = "layout floating tiling";
            alt-r = "flatten-workspace-tree";
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
            run = ["move-node-to-workspace 9"];
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
        ];
      };
    };
  };

  # Ghostty config
  home.file = {
    "/Users/ruimaciel/.config/ghostty/config".text = ''
      theme = catppuccin-frappe
      command = ${pkgs.fish}/bin/fish --login --interactive
      shell-integration = none
      font-size = 14
      font-thicken = true
      font-thicken-strength = 32
    '';
  };
}
