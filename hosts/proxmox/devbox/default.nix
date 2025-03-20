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

  services.rpcbind.enable = true;
  boot.supportedFilesystems = ["nfs"];

  systemd = {
    mounts = [
      {
        type = "nfs";
        mountConfig = {
          Options = [
            "nfsvers=4.2"
            "noatime"
            "timeo=50"
            "retrans=3"
            "soft"
          ];
        };
        what = "10.0.102.3:/";
        where = "/mnt/nas";
      }
    ];
    automounts = [
      {
        wantedBy = ["multi-user.target"];
        automountConfig = {
          TimeoutIdleSec = "600";
        };
        where = "/mnt/nas";
      }
    ];
  };
}
