{config, ...}: {
  imports = [../minimal-lxc];

  virtualisation.oci-containers.containers = {
    prowlarr = {
      image = "linuxserver/prowlarr@sha256:761f73534a01aec4bf72a1396e9b9fda3f01632948b3fa31985982d26120a330";
      ports = ["8080:9696"];
      environment = {
        TZ = config.time.timeZone;
      };
      volumes = [
        "config:/config"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [8080];
}
