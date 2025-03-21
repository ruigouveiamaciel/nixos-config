{
  config,
  lib,
  ...
}: let
  services = config.myNixOS.services.discovery.default;
in {
  imports = [../minimal-vm];

  networking.hostName = "vikunja";

  fileSystems = {
    "/mnt/config" = {
      device = "${services.nfs.ip}:/services/vikunja";
      fsType = "nfs";
      options = ["nfsvers=4.2" "bg"];
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

  systemd.services = lib.attrsets.mapAttrs' (_: {serviceName, ...}:
    lib.attrsets.nameValuePair serviceName rec {
      bindsTo = ["mnt-config.mount"];
      after = bindsTo;
      serviceConfig = {
        Restart = lib.mkForce "always";
        RestartSec = 60;
      };
    })
  config.virtualisation.oci-containers.containers;
}
