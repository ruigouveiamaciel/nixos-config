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
    ../../features/desktop/gaming
  ];

  networking = {
    hostName = "soyuz";
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
