{config, ...}: {
  virtualisation.oci-containers.containers = {
    sonarr = {
      autoStart = true;
      image = "linuxserver/sonarr@sha256:60e5edcac39172294ad22d55d1b08c2c0a9fe658cad2f2c4d742ae017d7874de";
      podman.sdnotify = "healthy";
      extraOptions = [
        "--network=podman-hostnet"
        "--ip=10.0.50.89"
        "--health-cmd"
        "curl -f http://localhost:8989 || exit 1"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = builtins.toString config.users.users.nobody.uid;
        PGID = builtins.toString config.users.groups.nogroup.gid;
      };
      volumes = [
        "/persist/services/sonarr:/config"
        "/persist/media/tvshows:/data/tvshows"
        "/persist/media/anime:/data/anime"
        "/persist/downloads:/downloads"
      ];
    };
  };
}
