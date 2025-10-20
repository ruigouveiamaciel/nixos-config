{
  lib,
  inputs,
  outputs,
  ...
}: {
  nix = {
    enable = true;
    settings = {
      trusted-users = ["root" "@admin"];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      extra-substituters = [
        "https://nix-community.cachix.org"
      ];
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
    };

    # Add each flake input as a registry
    # To make nix3 commands consistent with the flake
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

    # Add nixpkgs input to NIX_PATH
    # This lets nix2 commands still use <nixpkgs>
    nixPath = ["nixpkgs=${inputs.nixpkgs.outPath}"];
  };

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config.allowUnfree = true;
  };
}
