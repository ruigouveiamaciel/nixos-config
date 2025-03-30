{config, ...}: {
  imports = [../minimal-lxc];

  virtualisation.oci-containers.containers = {
    jellyseerr = {
      image = "fallenbagel/jellyseerr@sha256:52ca0b18c58ec4e769b8acae9beaae37a520a365c7ead52b7fc3ba1c3352d1f0";
      ports = ["8080:5055"];
      environment = {
        TZ = config.time.timeZone;
      };
      volumes = [
        "config:/app/config"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [8080];
}
