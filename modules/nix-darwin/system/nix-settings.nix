{
  nix = {
    enable = true;
    settings = rec {
      trusted-users = ["root" "@admin"];
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
    #   randomizedDelaySec = "300";
    #   dates = ["6:05"];
    # };
  };
}
