{
  config,
  lib,
  ...
}: {
  imports = [../minimal-vm];

  networking.hostName = "vikunja";

  services.rpcbind.enable = true;
  fileSystems = {
    "/mnt/config" = {
      device = "10.0.102.3:/services/vikunja";
      fsType = "nfs";
      options = ["nfsvers=4.2" "noatime"];
    };
  };

  virtualisation.oci-containers.containers = {
    vikunja = {
      image = "vikunja/vikunja@sha256:ed1f3ed467fecec0b57e9de7bc6607f8bbcbb23ffced6a81f5dfefc794cdbe3b";
      extraOptions = ["--network=host"];
      environment = {
        TZ = "Etc/UTC";
      };
      volumes = [
        "/mnt/config/files:/app/vikunja/files"
        "/mnt/config/database:/db"
      ];
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [3456];
  };

  systemd.services = let
    inherit (config.virtualisation.oci-containers) backend;
  in
    lib.attrsets.mapAttrs' (serviceName: _:
      lib.attrsets.nameValuePair "${backend}-${serviceName}" {
        bindsTo = ["mnt-config.mount"];
        after = ["mnt-config.mount"];
        serviceConfig = {
          Restart = lib.mkForce "always";
          RestartSec = 60;
        };
        startLimitBurst = 60;
        startLimitIntervalSec = 3600;
      })
    config.virtualisation.oci-containers.containers;
}
