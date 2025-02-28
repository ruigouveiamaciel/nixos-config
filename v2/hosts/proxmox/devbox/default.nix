{
  inputs,
  lib,
  modulesPath,
  config,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/profiles/minimal.nix")
    (modulesPath + "/profiles/headless.nix")

    inputs.disko.nixosModules.disko
    ./disko.nix

    ./openssh.nix
  ];

  myNixOS = {
    bundles.core.enable = true;

    networking = {
      openssh.enable = true;
      cloudflared.enable = true;
    };

    users.rui.enable = true;
  };

  sops.secrets.deploy-key = {
    sopsFile = ./secrets.yaml;
  };

  nix.settings.secret-key-files = [
    config.sops.secrets.deploy-key.path
  ];

  networking = {
    hostName = "devbox";
    useDHCP = lib.mkDefault true;
  };

  # QEMU Stuff
  boot.loader.systemd-boot.enable = true;
  services.qemuGuest.enable = true;
  boot.growPartition = lib.mkDefault true;
  fileSystems."/".autoResize = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "24.11";
}
