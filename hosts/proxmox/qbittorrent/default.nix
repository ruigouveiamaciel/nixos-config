{
  config,
  lib,
  ...
}: {
  imports = [
    ../minimal-vm
  ];

  networking.hostName = "qbittorrent";

  services.rpcbind.enable = true;
  fileSystems."/mnt/torrenting" = {
    device = "10.0.102.3:/torrenting";
    fsType = "nfs";
    options = ["nfsvers=4.2"];
  };

  virtualisation.oci-containers.containers = {
    qbittorrent = {
      image = "linuxserver/qbittorrent@sha256:50f490770308d0351e12618422e74e0613721b080f5db0bf840cf66a7281eea8";
      extraOptions = ["--network=host"];
      environment = {
        TZ = "Etc/UTC";
        WEBUI_PORT = "8080";
      };
      volumes = [
        "/mnt/torrenting/.qbittorrent:/config"
        "/mnt/torrenting/downloads:/downloads"
      ];
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [8080];
  };

  systemd.services = let
    inherit (config.virtualisation.oci-containers) backend;
  in
    lib.attrsets.mapAttrs' (serviceName: _:
      lib.attrsets.nameValuePair "${backend}-${serviceName}" {
        bindsTo = ["mnt-torrenting.mount"];
        after = ["mnt-torrenting.mount"];
        serviceConfig = {
          Restart = lib.mkForce "always";
          RestartSec = 60;
        };
        startLimitBurst = 60;
        startLimitIntervalSec = 3600;
      })
    config.virtualisation.oci-containers.containers;
}
