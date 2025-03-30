{config, ...}: {
  imports = [../minimal-lxc];

  virtualisation.oci-containers.containers = {
    flood = {
      image = "jesec/flood@sha256:e9c8a3fd460ad1e81b47e7e17ec257a998f4e92e2b8c4935190d63c28e5b9b50";
      ports = ["8080:3000"];
      environment = {
        TZ = config.time.timeZone;
        HOME = "/config";
      };
      volumes = [
        "config:/config"
        "downloads:/downloads:ro"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [8080];
}
