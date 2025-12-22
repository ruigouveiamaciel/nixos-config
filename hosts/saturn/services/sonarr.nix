{config, ...}: {
  virtualisation.oci-containers.containers = {
    sonarr = {
      autoStart = true;
      image = "docker.io/linuxserver/sonarr@sha256:60e5edcac39172294ad22d55d1b08c2c0a9fe658cad2f2c4d742ae017d7874de";
      podman = {
        sdnotify = "healthy";
        user = "sonarr";
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
        "curl -f http://localhost:8989 || exit 1"
        "--health-interval"
        "30s"
        "--health-retries"
        "3"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = builtins.toString config.users.users.sonarr.uid;
        PGID = builtins.toString config.users.groups.sonarr.gid;
      };
      ports = [
        "8989:8989/tcp"
      ];
      volumes = [
        "/persist/services/sonarr:/config"
        "/persist/media/tvshows:/data/tvshows"
        "/persist/media/anime:/data/anime"
        "/persist/downloads:/downloads"
      ];
    };
  };

  users.users.sonarr = {
    isNormalUser = true;
    linger = true;
    packages = [config.virtualisation.podman.package];
    uid = 1013;
    group = "sonarr";
  };

  users.groups.sonarr = {
    gid = 1013;
  };

  networking.firewall.allowedTCPPorts = [
    8989
  ];

  boot.postBootCommands = ''
    mkdir -p /persist/services/sonarr
    chown -R ${config.users.users.sonarr.uid}:${config.users.groups.sonarr.gid} /persist/services/sonarr
    chmod -R 750 /persist/services/sonarr
  '';
}
