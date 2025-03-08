_: {
  myDarwin = {
    nix = {
      nix-settings.enable = true;
      home-manager.enable = true;
      homebrew.enable = true;
      nix-index.enable = true;
    };
    users.rui = {
      enable = true;
      extraHomeManagerConfigFile = ./extraHome.nix;
    };
    shell.fish.enable = true;
  };

  programs.fish.shellAliases = {
    "rebuild" = "cd ~/nixos-config && darwin-rebuild switch --flake .#darwin-work";
  };

  homebrew.casks = [
    "raycast"
    "spotify"
    "slack"
    "notunes"
    "scroll-reverser"
    "waterfox"
    "ghostty"
    "microsoft-teams"
    "microsoft-outlook"
    "capslocknodelay"
    "alt-tab"
  ];

  # TODO: Setup tmux

  services.aerospace = {
    enable = true;
    settings = {
      on-focus-changed = ["move-mouse window-lazy-center"];
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

          alt-h = "focus left";
          alt-j = "focus down";
          alt-k = "focus up";
          alt-l = "focus right";

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

          alt-shift-f1 = "move-node-to-workspace 1";
          alt-shift-f2 = "move-node-to-workspace 2";
          alt-shift-f3 = "move-node-to-workspace 3";
          alt-shift-f4 = "move-node-to-workspace 4";
          alt-shift-f5 = "move-node-to-workspace 5";
          alt-shift-f6 = "move-node-to-workspace 6";
          alt-shift-f7 = "move-node-to-workspace 7";
          alt-shift-f8 = "move-node-to-workspace 8";
          alt-shift-f9 = "move-node-to-workspace 9";
          alt-shift-f10 = "move-node-to-workspace 10";

          alt-tab = "workspace-back-and-forth";
          alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

          alt-f = "layout floating tiling";
          alt-r = "flatten-workspace-tree";
        };
      };
    };
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 5;
}
