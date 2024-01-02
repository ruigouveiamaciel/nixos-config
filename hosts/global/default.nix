{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports =
    [
      inputs.home-manager.nixosModules.home-manager

      ./nix.nix
      ./fish.nix
      ./locale.nix
      ./openssh.nix
      ./sops.nix
      ./systemd-initrd.nix
      ./git.nix
      ./podman.nix
      ./impermanence.nix
      ./nix-ld.nix
      ./cloudflare.nix
      ./docker.nix
    ]
    ++ builtins.attrValues outputs.nixosModules;

  home-manager.extraSpecialArgs = {
    inherit inputs outputs;
  };

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
    };
  };
}
