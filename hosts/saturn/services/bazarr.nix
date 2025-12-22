{config, ...}: {
  virtualisation.oci-containers.containers = {
    bazarr = {
      autoStart = true;
      image = "docker.io/linuxserver/bazarr@sha256:bd481eaad7f694a5b13f7163321466d30c8ae29a503346888d69f8dc8267be9c";
      podman = {
        sdnotify = "healthy";
        user = "bazarr";
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
        "curl -f http://localhost:6767 || exit 1"
        "--health-interval"
        "30s"
        "--health-retries"
        "3"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = builtins.toString config.users.users.bazarr.uid;
        PGID = builtins.toString config.users.groups.bazarr.gid;
      };
      ports = [
        "6767:6767/tcp"
      ];
      volumes = [
        "/persist/services/bazarr:/config"
        "/persist/media/tvshows:/data/tvshows"
        "/persist/media/anime:/data/anime"
        "/persist/media/movies:/data/movies"
      ];
    };
  };

  users.users.bazarr = {
    isNormalUser = true;
    linger = true;
    packages = [config.virtualisation.podman.package];
    uid = 1001;
    group = "bazarr";
  };

  users.groups.bazarr = {
    gid = 1001;
  };

  networking.firewall.allowedTCPPorts = [
    6767
  ];

  boot.postBootCommands = ''
    mkdir -p /persist/services/bazarr
    chown -R ${builtins.toString config.users.users.bazarr.uid}:${builtins.toString config.users.groups.bazarr.gid} /persist/services/bazarr
    chmod -R 750 /persist/services/bazarr
  '';
}
