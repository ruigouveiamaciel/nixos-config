{
  lib,
  modulesPath,
  config,
  inputs,
  ...
}: {
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    (modulesPath + "/profiles/minimal.nix")
    inputs.nixos-generators.nixosModules.all-formats
  ];

  proxmoxLXC = {
    manageNetwork = false;
    privileged = false;
  };

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

  sops.useTmpfs = lib.mkForce true;

  users.users.root.openssh.authorizedKeys.keys = config.myNixOS.users.authorized-keys.users.rui;
  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";

  networking = {
    hostName = lib.mkDefault "minimal";
    useDHCP = lib.mkForce true;
  };

  zramSwap.enable = true;
  systemd.oomd.enable = false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "24.11";
}
