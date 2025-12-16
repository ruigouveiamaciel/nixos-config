{config, ...}: {
  virtualisation.oci-containers.containers = {
    radarr = {
      autoStart = true;
      image = "linuxserver/radarr@sha256:01cc56407b31eabfac70d964424fbe9f25506b3e270e1347150828b1456d19d6";
      podman.sdnotify = "healthy";
      extraOptions = [
        "--network=podman-hostnet"
        "--ip=10.0.50.78"
        "--health-cmd"
        "curl -f http://localhost:7878 || exit 1"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = builtins.toString config.users.users.nobody.uid;
        PGID = builtins.toString config.users.groups.nogroup.gid;
      };
      volumes = [
        "/persist/services/radarr:/config"
        "/persist/media/movies:/data/movies"
        "/persist/downloads:/data/downloads"
      ];
    };
  };
}
