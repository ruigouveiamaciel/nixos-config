{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    myNeovim
  ];

  myDarwin = {
    nix = {
      nix-settings.enable = true;
      home-manager.enable = true;
      homebrew.enable = true;
    };
    users.rui.enable = true;
    shell.fish.enable = true;
  };

  programs.fish.shellAliases = {
    "rebuild" = "cd ~/nixos-config/ && darwin-rebuild switch --flake .#darwin-work";
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
  ];

  power = {
    sleep = {
      display = 4;
      computer = 5;
    };
  };

  programs = {
    nix-index.enable = true;
  };

  # TODO: Setup tmux
  # TODO: Setup aerospace
  # TODO: Setup ghostty config
  # TODO: Setup git

  system = {
    defaults = {
      NSGlobalDomain = {
        AppleEnableMouseSwipeNavigateWithScrolls = false;
        AppleEnableSwipeNavigateWithScrolls = false;
        AppleICUForce24HourTime = true;
        AppleInterfaceStyle = "Dark";
        AppleInterfaceStyleSwitchesAutomatically = false;
        ApplePressAndHoldEnabled = false;
        AppleScrollerPagingBehavior = true;
        AppleShowAllExtensions = true;
        AppleShowScrollBars = "Automatic";
        InitialKeyRepeat = 25;
        KeyRepeat = 2;
      };
    };
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 5;
}
