{config, ...}: {
  virtualisation.oci-containers.containers = {
    navidrome = {
      autoStart = true;
      image = "docker.io/deluan/navidrome@sha256:97533639adaafd3b968d9a3736895945ddf0ed7b4dec3a6102af334274cb7083";
      podman = {
        sdnotify = "healthy";
        user = "navidrome";
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
        "curl -f http://localhost:4533 || exit 1"
        "--health-interval"
        "30s"
        "--health-retries"
        "3"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = builtins.toString config.users.users.navidrome.uid;
        PGID = builtins.toString config.users.groups.navidrome.gid;
      };
      ports = [
        "4533:4533/tcp"
      ];
      volumes = [
        "/persist/services/navidrome:/data"
        "/persist/media/music:/music:ro"
      ];
    };
  };

  users.users.navidrome = {
    isNormalUser = true;
    linger = true;
    packages = [config.virtualisation.podman.package];
    uid = 1009;
    group = "navidrome";
  };

  users.groups.navidrome = {
    gid = 1009;
  };

  networking.firewall.allowedTCPPorts = [
    4533
  ];

  boot.postBootCommands = ''
    mkdir -p /persist/services/navidrome
    chown -R ${config.users.users.navidrome.uid}:${config.users.groups.navidrome.gid} /persist/services/navidrome
    chmod -R 750 /persist/services/navidrome
  '';
}
