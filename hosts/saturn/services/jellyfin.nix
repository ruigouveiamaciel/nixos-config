{config, ...}: {
  virtualisation.oci-containers.containers = {
    jellyfin = {
      autoStart = true;
      image = "docker.io/jellyfin/jellyfin@sha256:6d819e9ab067efcf712993b23455cc100ee5585919bb297ea5a109ac00cb626e";
      podman = {
        sdnotify = "healthy";
        user = "jellyfin";
      };
      extraOptions = [
        "--cap-drop=ALL"
        "--userns=keep-id"
        "--device=/dev/dri/renderD128:/dev/dri/renderD128"
        "--health-cmd"
        "curl -f http://localhost:8096 || exit 1"
        "--health-interval"
        "30s"
        "--health-retries"
        "3"
      ];
      ports = [
        "8096:8096/tcp"
      ];
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

  users.users.jellyfin = {
    isNormalUser = true;
    linger = true;
    packages = [config.virtualisation.podman.package];
    uid = 1007;
    group = "jellyfin";
  };

  users.groups.jellyfin = {
    gid = 1007;
  };

  networking.firewall.allowedTCPPorts = [
    8096
  ];

  boot.postBootCommands = ''
    mkdir -p /persist/services/jellyfin
    chown -R ${builtins.toString config.users.users.jellyfin.uid}:${builtins.toString config.users.groups.jellyfin.gid} /persist/services/jellyfin
    chmod -R 750 /persist/services/jellyfin
  '';
}
