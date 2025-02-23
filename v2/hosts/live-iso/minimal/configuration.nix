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

  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";

  myNixOS = {
    bundles.core.enable = true;
    networking.openssh.enable = true;
    users = {
      enable = true;
      rui.enable = true;
      users = {
        nixos = {
          authorizedKeys = config.myNixOS.users.authorized-keys.users.rui;
          homeManagerConfigFile = ./home/nixos.nix;
        };
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
