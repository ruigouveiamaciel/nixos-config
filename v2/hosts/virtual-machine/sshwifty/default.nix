{
  inputs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix

    inputs.disko.nixosModules.disko
    ./disko.nix

    ./openssh.nix
  ];

  boot.loader.systemd-boot.enable = true;

  myNixOS = {
    bundles.core.enable = true;
    bundles.server.enable = true;

    users.rui.enable = true;
  };

  boot.growPartition = lib.mkDefault true;
  fileSystems."/".autoResize = true;

  networking = {
    hostName = "sshwifty";
    useDHCP = lib.mkForce true;
  };

  services.qemuGuest.enable = true;

  system.stateVersion = "24.11";
}
