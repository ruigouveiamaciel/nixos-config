{
  inputs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix

    inputs.disko.nixosModules.disko
    ./filesystems.nix

    ./openssh.nix
  ];

  myNixOS = {
    bootloader.grub.enable = true;
    bundles.core.enable = true;
    users.rui.enable = true;
  };

  boot.growPartition = lib.mkDefault true;
  fileSystems."/".autoResize = true;

  networking = {
    hostName = "devbox";
    useDHCP = lib.mkDefault true;
  };

  services.qemuGuest.enable = true;

  system.stateVersion = "24.11";
}
