{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware-configuration.nix
    ../../optional/boot/systemd-boot.nix

    ../../global
    ../../optional/desktop/gnome
    ../../optional/desktop/wireless
    ../../optional/desktop/gaming
  ];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  networking = {
    hostName = "soyuz";
  };

  sops.secrets.soyuz-machine-id = {
    sopsFile = ./secrets.yaml;
    mode = "0644";
  };

  environment.etc.machine-id.source = config.sops.secrets.soyuz-machine-id.path;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
