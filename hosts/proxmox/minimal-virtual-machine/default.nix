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
  ];

  myNixOS = {
    locales.pt-pt.enable = true;
    networking.openssh.enable = true;
    security.disable-lecture.enable = true;
    nix = {
      nix-settings.enable = true;
      sops.enable = true;
    };
    users.authorized-keys.enable = true;
  };

  users.users.root.openssh.authorizedKeys.keys = config.myNixOS.users.authorized-keys.users.rui;
  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";

  networking = {
    hostName = lib.mkDefault "minimal";
    useDHCP = lib.mkForce true;
  };

  # QEMU Stuff
  boot = {
    loader.systemd-boot = {
      enable = true;
      configurationLimit = 3;
    };
    growPartition = lib.mkDefault true;
  };
  fileSystems."/".autoResize = true;

  services.qemuGuest.enable = true;
  zramSwap.enable = true;
  systemd.oomd.enable = false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "24.11";
}
