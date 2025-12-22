{config, ...}: {
  virtualisation.oci-containers.containers = {
    radarr = {
      autoStart = true;
      image = "docker.io/linuxserver/radarr@sha256:01cc56407b31eabfac70d964424fbe9f25506b3e270e1347150828b1456d19d6";
      podman = {
        sdnotify = "healthy";
        user = "radarr";
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
        "--health-cmd"
        "curl -f http://localhost:7878 || exit 1"
        "--health-interval"
        "30s"
        "--health-retries"
        "3"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = builtins.toString config.users.users.radarr.uid;
        PGID = builtins.toString config.users.groups.radarr.gid;
      };
      ports = [
        "7878:7878/tcp"
      ];
      volumes = [
        "/persist/services/radarr:/config"
        "/persist/media/movies:/data/movies"
        "/persist/downloads:/downloads"
      ];
    };
  };

  users.users.radarr = {
    isNormalUser = true;
    linger = true;
    packages = [config.virtualisation.podman.package];
    uid = 1012;
    group = "radarr";
  };

  users.groups.radarr = {
    gid = 1012;
  };

  networking.firewall.allowedTCPPorts = [
    7878
  ];

  boot.postBootCommands = ''
    mkdir -p /persist/services/radarr
    chown -R ${config.users.users.radarr.uid}:${config.users.groups.radarr.gid} /persist/services/radarr
    chmod -R 750 /persist/services/radarr
  '';
}
