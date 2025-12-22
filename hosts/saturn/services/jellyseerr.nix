{config, ...}: {
  virtualisation.oci-containers.containers = {
    jellyseerr = {
      autoStart = true;
      image = "ghcr.io/fallenbagel/jellyseerr@sha256:9cc9e9ee6cd5cf5a23feb45c37742ba34cfd6314d81d259cddb373a97ac92cdd";
      podman = {
        sdnotify = "healthy";
        user = "jellyseerr";
      };
      extraOptions = [
        "--cap-drop=ALL"
        "--userns=keep-id"
        "--health-cmd"
        "wget --no-verbose --tries=1 --spider http://localhost:5055/api/v1/status || exit 1"
        "--health-interval"
        "30s"
        "--health-retries"
        "3"
      ];
      ports = [
        "5055:5055/tcp"
      ];
      volumes = [
        "/persist/services/jellyseerr:/app/config"
      ];
    };
  };

  users.users.jellyseerr = {
    isNormalUser = true;
    linger = true;
    packages = [config.virtualisation.podman.package];
    uid = 1007;
    group = "jellyseerr";
  };

  users.groups.jellyseerr = {
    gid = 1007;
  };

  networking.firewall.allowedTCPPorts = [
    8096
  ];

  boot.postBootCommands = ''
    mkdir -p /persist/services/jellyseerr
    chown -R ${config.users.users.jellyseerr.uid}:${config.users.groups.jellyseerr.gid} /persist/services/jellyseerr
    chmod -R 750 /persist/services/jellyseerr
  '';
}
