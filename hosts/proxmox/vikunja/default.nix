{
  config,
  lib,
  ...
}: let
  services = config.myNixOS.services.discovery.default;
in {
  imports = [../minimal-vm];

  networking.hostName = "vikunja";

  services.rpcbind.enable = true;
  fileSystems = {
    "/mnt/config" = {
      device = "${services.nfs.ip}:/services/vikunja";
      fsType = "nfs";
      options = ["nfsvers=4.2" "noatime" "bg" "_netdev"];
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
      lib.attrsets.nameValuePair "${backend}-${serviceName}" rec {
        bindsTo = ["mnt-config.mount"];
        after = bindsTo;
        serviceConfig = {
          Restart = lib.mkForce "always";
          RestartSec = 60;
        };
      })
    config.virtualisation.oci-containers.containers;
}
