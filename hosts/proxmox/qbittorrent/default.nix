{
  config,
  lib,
  ...
}: let
  services = config.myNixOS.services.discovery.default;
in {
  imports = [
    ../minimal-vm
  ];

  networking.hostName = "qbittorrent";

  fileSystems = {
    "/mnt/config" = {
      device = "${services.nfs.ip}:/services/qbittorrent";
      fsType = "nfs";
      options = ["nfsvers=4.2" "bg" "noatime"];
    };
    "/mnt/downloads" = {
      device = "${services.nfs.ip}:/downloads";
      fsType = "nfs";
      options = ["nfsvers=4.2" "bg" "noatime"];
    };
  };

  virtualisation.oci-containers.containers = {
    qbittorrent = {
      image = "linuxserver/qbittorrent@sha256:50f490770308d0351e12618422e74e0613721b080f5db0bf840cf66a7281eea8";
      extraOptions = ["--network=host"];
      environment = {
        TZ = "Etc/UTC";
        WEBUI_PORT = "8080";
        HOME = "/config";
      };
      volumes = [
        "/mnt/config:/config"
        "/mnt/downloads:/downloads"
      ];
    };
    flood = {
      image = "jesec/flood@sha256:e9c8a3fd460ad1e81b47e7e17ec257a998f4e92e2b8c4935190d63c28e5b9b50";
      extraOptions = ["--network=host"];
      environment = {
        TZ = "Etc/UTC";
        HOME = "/config";
      };
      volumes = [
        "/mnt/config:/config"
        "/mnt/downloads:/downloads:ro"
      ];
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [8080 3000];
  };

  systemd.services = lib.attrsets.mapAttrs' (_: {serviceName, ...}:
    lib.attrsets.nameValuePair serviceName rec {
      bindsTo = ["mnt-config.mount" "mnt-downloads.mount"];
      after = bindsTo;
      serviceConfig = {
        Restart = lib.mkForce "always";
        RestartSec = 60;
      };
    })
  config.virtualisation.oci-containers.containers;
}
