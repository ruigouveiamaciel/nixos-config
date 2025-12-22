{config, ...}: {
  virtualisation.oci-containers.containers = {
    flood = {
      autoStart = true;
      image = "docker.io/jesec/flood@sha256:fa5722fc637ad494cf347959f89d67c5a95ca42306495a814ca0a8b10c5374aa";
      podman = {
        sdnotify = "healthy";
        user = "flood";
      };
      extraOptions = [
        "--cap-drop=ALL"
        "--userns=keep-id"
        "--health-cmd"
        "curl -f http://localhost:3000/login || exit 1"
        "--health-interval"
        "30s"
        "--health-retries"
        "3"
      ];
      ports = [
        "1337:3000/tcp"
      ];
      volumes = [
        "/persist/services/flood:/usr/src/app"
        "/persist/downloads:/data:ro"
      ];
    };
  };

  users.users.flood = {
    isNormalUser = true;
    linger = true;
    packages = [config.virtualisation.podman.package];
    uid = 1003;
    group = "flood";
  };

  users.groups.flood = {
    gid = 1003;
  };

  networking.firewall.allowedTCPPorts = [
    1337
  ];

  boot.postBootCommands = ''
    mkdir -p /persist/services/flood
    chown -R ${config.users.users.flood.uid}:${config.users.groups.flood.gid} /persist/services/flood
    chmod -R 750 /persist/services/flood
  '';
}
