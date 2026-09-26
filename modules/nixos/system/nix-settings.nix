{inputs, ...}: {
  programs.command-not-found.enable = false;

  nix = {
    settings = {
      trusted-users = ["root" "@wheel"];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      substituters = [
        "https://nix-community.cachix.org"
      ];
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
    };
    optimise = {
      automatic = true;
      persistent = true;
      dates = ["6:05"];
      randomizedDelaySec = "300";
    };
    gc = {
      automatic = true;
      persistent = true;
      dates = ["4:05"];
      options = "--delete-older-than +7";
    };
    registry =
      builtins.mapAttrs
      (_: flake: {inherit flake;})
      inputs;
  };
}
