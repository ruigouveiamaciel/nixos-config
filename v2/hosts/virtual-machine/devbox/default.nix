{
  inputs,
  lib,
  config,
  ...
}: {
  imports = [
    ./hardware-configuration.nix

    inputs.disko.nixosModules.disko
    ./disko.nix

    ./openssh.nix
  ];

  myNixOS = {
    bootloader.grub.enable = true;

    bundles.core.enable = true;
    bundles.server.enable = true;

    users = {
      rui.enable = true;
      users.rui = {
        hashedPasswordFile = config.sops.secrets.ssh-password.path;
      };
    };
  };

  services.openssh.extraConfig = ''
    Match User rui Address 10.0.100.3
        PasswordAuthentication yes
  '';

  sops.secrets.ssh-password = {
    sopsFile = ./secrets.yaml;
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
