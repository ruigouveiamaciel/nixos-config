{config, ...}: {
  virtualisation.oci-containers.containers = {
    jellyseerr = {
      autoStart = true;
      image = "ghcr.io/fallenbagel/jellyseerr@sha256:9cc9e9ee6cd5cf5a23feb45c37742ba34cfd6314d81d259cddb373a97ac92cdd";
      podman.sdnotify = "healthy";
      extraOptions = [
        "--network=podman-hostnet"
        "--ip=10.0.50.55"
        "--health-cmd"
        "wget --no-verbose --tries=1 --spider http://localhost:5055/api/v1/status || exit 1"
      ];
      environment = {
        TZ = config.time.timeZone;
      };
      volumes = [
        "/persist/services/jellyseerr:/app/config"
      ];
    };
  };
}
