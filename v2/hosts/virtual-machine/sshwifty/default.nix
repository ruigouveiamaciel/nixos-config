{
  inputs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix

    inputs.disko.nixosModules.disko
    ./disko.nix
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

  security.sudo.extraRules = [
    {
      users = ["rui"];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  nix.settings.require-sigs = false;
  nix.settings.secret-key-files = [];

  system.stateVersion = "24.11";
}
