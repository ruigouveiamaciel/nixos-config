{
  lib,
  config,
  ...
}: {
  imports = [
    ../minimal-vm

    ./openssh.nix
  ];

  myNixOS = {
    bundles.core.enable = true;
    networking.cloudflared.enable = true;

    users.rui.enable = true;
  };

  sops.secrets.deploy-key = {
    sopsFile = ./secrets.yaml;
  };

  nix.settings.secret-key-files = [
    config.sops.secrets.deploy-key.path
  ];

  networking.hostName = "devbox";
  nixpkgs.hostPlatform = lib.mkForce "x86_64-linux";
  system.stateVersion = lib.mkForce "24.11";

  services.rpcbind.enable = true; # needed for NFS
  fileSystems."/mnt/media" = {
    device = "10.0.102.3:/media";
    fsType = "nfs";
    options = ["nfsvers=4.2"];
  };
}
