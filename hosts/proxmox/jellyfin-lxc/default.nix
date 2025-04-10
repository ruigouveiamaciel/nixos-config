{config, ...}: {
  imports = [../minimal-lxc];

  virtualisation.oci-containers.containers = {
    jellyfin = {
      image = "jellyfin/jellyfin@sha256:96b09723b22fdde74283274bdc1f63b9b76768afd6045dd80d4a4559fc4bb7f3";
      extraOptions = ["--device=/dev/dri/renderD128:/dev/dri/renderD128"];
      ports = ["8080:8096"];
      environment = {
        TZ = config.time.timeZone;
      };
      volumes = [
        "config:/config"
        "cache:/cache"
        "tvshows:/data/tvshows:ro"
        "anime:/data/anime:ro"
        "movies:/data/movies:ro"
        "personal:/data/personal:ro"
        "test:/data/test:ro"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [8080];
}
