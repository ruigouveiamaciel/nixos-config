{
  inputs,
  lib,
  modulesPath,
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
    locale.pt-pt.enable = true;
    networking.openssh.enable = true;
    nix = {
      nix-settings.enable = true;
      sops.enable = true;
    };
    security = {
      disable-lecture.enable = true;
      sudo-using-ssh-agent.enable = true;
    };
    users.admin.enable = true;
  };

  environment.defaultPackages = [];

  networking = {
    hostName = "minimal";
    useDHCP = lib.mkForce true;
  };

  #nix.settings.require-sigs = false;
  #nix.settings.secret-key-files = [];
  nix.settings.trusted-public-keys = ["deploy-key:VRnp+EA2o8IqWp2YgUI41gtvQaeG/OI6nj5Rg+r0yZA="];

  # QEMU Stuff
  boot.loader.systemd-boot.enable = true;
  services.qemuGuest.enable = true;
  boot.growPartition = lib.mkDefault true;
  fileSystems."/".autoResize = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "24.11";
}
