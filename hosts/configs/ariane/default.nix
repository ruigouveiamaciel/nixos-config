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

    ../global.nix

    ../../features/boot/systemd-boot.nix
    ../../features/desktop/gnome
    ../../features/desktop/gaming
    ../../features/networking/network-manager.nix
  ];

  networking = {
    hostName = "ariane";
  };

  sops.secrets.ariane-machine-id = {
    sopsFile = ./secrets.yaml;
    mode = "0644";
    neededForUsers = true;
  };

  # Some applications will invalidate their credentials if the machine-id
  # changes.
  environment.etc.machine-id.source = config.sops.secrets.ariane-machine-id.path;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
