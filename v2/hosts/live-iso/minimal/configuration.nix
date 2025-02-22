{
  pkgs,
  lib,
  modulesPath,
  config,
  ...
}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  myNixOS = {
    bundles.core.enable = true;
    networking.openssh.enable = true;
    nix.home-manager.enable = true;
    users = {
      enable = true;
      users.nixos = {
        inherit (config.myNixOS.users.users.rui) authorizedKeys;
        homeManagerConfigFile = ./home.nix;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    parted
    disko
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "24.11";
}
