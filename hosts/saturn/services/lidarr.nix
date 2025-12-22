{config, ...}: {
  virtualisation.oci-containers.containers = {
    lidarr = {
      autoStart = true;
      image = "docker.io/linuxserver/lidarr@sha256:cfd9fe71f4706e87e9173f1f41740d4b52cda70e2897df7d39d93e6731f3b5d4";
      podman = {
        sdnotify = "healthy";
        user = "lidarr";
      };
      capabilities = {
        CAP_SETUID = true;
        CAP_SETGID = true;
        CAP_CHOWN = true;
        CAP_FOWNER = true;
        CAP_DAC_OVERRIDE = true;
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
      environment = {
        TZ = config.time.timeZone;
        PUID = builtins.toString config.users.users.lidarr.uid;
        PGID = builtins.toString config.users.groups.lidarr.gid;
      };
      ports = [
        "8686:8686/tcp"
      ];
      volumes = [
        "/persist/services/lidarr:/config"
        "/persist/media/music:/music"
        "/persist/downloads:/downloads"
      ];
    };
  };

  users.users.lidarr = {
    isNormalUser = true;
    linger = true;
    packages = [config.virtualisation.podman.package];
    uid = 1008;
    group = "lidarr";
  };

  users.groups.lidarr = {
    gid = 1008;
  };

  networking.firewall.allowedTCPPorts = [
    8686
  ];

  boot.postBootCommands = ''
    mkdir -p /persist/services/lidarr
    chown -R ${config.users.users.lidarr.uid}:${config.users.groups.lidarr.gid} /persist/services/lidarr
    chmod -R 750 /persist/services/lidarr
  '';
}
