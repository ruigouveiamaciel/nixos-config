{
  lib,
  inputs,
  outputs,
  ...
}: {
  config = {
    programs.command-not-found.enable = false;

    nix = {
      settings = rec {
        trusted-users = ["root" "@wheel"];
        trusted-public-keys = [
          "deploy-key:VRnp+EA2o8IqWp2YgUI41gtvQaeG/OI6nj5Rg+r0yZA="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        ];
        trusted-substituters = [
          "https://nix-community.cachix.org"
          "https://hyprland.cachix.org"
        ];
        substituters = trusted-substituters;
        auto-optimise-store = true;
        experimental-features = ["nix-command" "flakes"];
        warn-dirty = false;
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than +7";
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
  };
}
