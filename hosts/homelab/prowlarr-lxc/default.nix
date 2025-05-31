{config, ...}: {
  imports = [../minimal-lxc];

  virtualisation.oci-containers.containers = {
    prowlarr = {
      image = "linuxserver/prowlarr@sha256:2611b04166440455966b64928dbb082819f10e9ca27db56e2f234d755b767ad4";
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
