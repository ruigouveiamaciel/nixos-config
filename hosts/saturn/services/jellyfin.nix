{config, ...}: {
  virtualisation.oci-containers.containers = {
    jellyfin = {
      autoStart = true;
      image = "jellyfin/jellyfin@sha256:6d819e9ab067efcf712993b23455cc100ee5585919bb297ea5a109ac00cb626e";
      extraOptions = [
        "--network=podman-hostnet"
        "--ip=10.0.50.10"
        "--device=/dev/dri/renderD128:/dev/dri/renderD128"
      ];
      environment = {
        TZ = config.time.timeZone;
      };
      volumes = [
        "/persist/services/jellyfin/config:/config"
        "/persist/services/jellyfin/cache:/cache"
        "/persist/media/movies:/data/movies:ro"
        "/persist/media/tvshows:/data/tvshows:ro"
        "/persist/media/anime:/data/anime:ro"
        "/persist/media/test:/data/test:ro"
        "/persist/media/personal:/data/personal:ro"
      ];
    };
  };
}
