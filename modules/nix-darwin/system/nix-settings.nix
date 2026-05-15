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
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
    };
  };
}
