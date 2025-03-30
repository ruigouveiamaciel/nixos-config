{config, ...}: {
  imports = [../minimal-lxc];

  virtualisation.oci-containers.containers = {
    sonarr = {
      image = "linuxserver/sonarr@sha256:49a8e636fd4514b23d37c84660101fecbb632174ba0569e0f09bbd2659a2a925";
      ports = ["8080:8989"];
      environment = {
        TZ = config.time.timeZone;
      };
      volumes = [
        "config:/config"
        "downloads:/downloads"
        "tvshows:/data/tvshows"
        "anime:/data/anime"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [8080];
}
