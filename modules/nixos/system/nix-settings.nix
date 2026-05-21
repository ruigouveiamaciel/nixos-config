{
  programs.command-not-found.enable = false;

  nix = {
    settings = rec {
      trusted-users = ["root" "@wheel"];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-substituters = [
        "https://nix-community.cachix.org"
      ];
      substituters = trusted-substituters;
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
    };
    # TODO: Added in 26.05, time of writting is 25.11
    # optimise = {
    #   automatic = true;
    #   persistent = true;
    #   dates = ["6:05"];
    #   randomizedDelaySec = "300";
    # };
    # gc = {
    #   automatic = true;
    #   persistent = true;
    #   dates = ["4:05"];
    #   options = "--delete-older-than +7";
    # };
  };
}
