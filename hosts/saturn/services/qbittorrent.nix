{config, ...}: {
  virtualisation.oci-containers.containers = {
    qbittorrent = {
      autoStart = true;
      image = "linuxserver/qbittorrent@sha256:043498de39c3dd63eec94360c5ad966a51271d1581070f42cb73ab0cf4776f29";
      podman.sdnotify = "healthy";
      extraOptions = [
        "--network=podman-hostnet"
        "--ip=10.0.50.38"
        "--health-cmd"
        "curl -f http://localhost:8080 || exit 1"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = builtins.toString config.users.users.nobody.uid;
        PGID = builtins.toString config.users.groups.nogroup.gid;
        WEBUI_PORT = "8080";
      };
      volumes = [
        "/persist/services/qbittorrent:/config"
        "/persist/downloads:/downloads"
      ];
    };
  };
}
