{config, ...}: {
  virtualisation.oci-containers.containers = {
    qbittorrent = {
      autoStart = true;
      image = "docker.io/linuxserver/qbittorrent@sha256:043498de39c3dd63eec94360c5ad966a51271d1581070f42cb73ab0cf4776f29";
      podman = {
        sdnotify = "healthy";
        user = "qbittorrent";
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
        "curl -f http://localhost:1338 || exit 1"
        "--health-interval"
        "30s"
        "--health-retries"
        "3"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = builtins.toString config.users.users.qbittorrent.uid;
        PGID = builtins.toString config.users.groups.qbittorrent.gid;
        WEBUI_PORT = "1338";
      };
      ports = [
        "1338:1338/tcp"
      ];
      volumes = [
        "/persist/services/qbittorrent:/config"
        "/persist/downloads:/downloads"
      ];
    };
  };

  users.users.qbittorrent = {
    isNormalUser = true;
    linger = true;
    packages = [config.virtualisation.podman.package];
    uid = 1011;
    group = "qbittorrent";
  };

  users.groups.qbittorrent = {
    gid = 1011;
  };

  networking.firewall.allowedTCPPorts = [
    1338
  ];

  boot.postBootCommands = ''
    mkdir -p /persist/services/qbittorrent
    chown -R ${builtins.toString config.users.users.qbittorrent.uid}:${builtins.toString config.users.groups.qbittorrent.gid} /persist/services/qbittorrent
    chmod -R 750 /persist/services/qbittorrent
  '';
}
