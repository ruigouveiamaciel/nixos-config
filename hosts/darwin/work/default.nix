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

  system.primaryUser = "ruimaciel";

  homebrew = {
    casks = [
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
      "keymapp"
      "google-chrome"
      "obsidian"
    ];
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 5;
}
