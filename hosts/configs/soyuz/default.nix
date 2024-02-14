{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ./hardware.nix
    ./power-management.nix

    ../global.nix

    ../../features/boot/systemd-boot.nix
    ../../features/desktop/gnome
    #../../features/networking/wireless.nix
    ../../features/networking/network-manager.nix
    ../../features/desktop/gaming
  ];

  networking = {
    hostName = "soyuz";
  };

  sops.secrets.soyuz-machine-id = {
    sopsFile = ./secrets.yaml;
    mode = "0644";
    neededForUsers = true;
  };

  # Some applications will invalidate their credentials if the machine-id
  # changes.
  environment.etc.machine-id.source = config.sops.secrets.soyuz-machine-id.path;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
