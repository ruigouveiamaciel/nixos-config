{config, ...}: {
  virtualisation.oci-containers.containers = {
    flaresolverr = {
      autoStart = true;
      image = "docker.io/flaresolverr/flaresolverr:latest";
      pull = "newer";
      podman = {
        sdnotify = "healthy";
        user = "flaresolverr";
      };
      extraOptions = [
        "--cap-drop=ALL"
        "--userns=keep-id"
        "--health-cmd"
        "curl -f http://localhost:8191 || exit 1"
        "--health-interval"
        "5s"
        "--health-retries"
        "6"
      ];
      ports = [
        "10.0.50.42:8191:8191/tcp"
      ];
      volumes = [
        "/persist/services/flaresolverr:/config"
      ];
    };
  };

  users.users.flaresolverr = {
    isNormalUser = true;
    linger = true;
    packages = [config.virtualisation.podman.package];
    uid = 1002;
    group = "flaresolverr";
  };

  users.groups.flaresolverr = {
    gid = 1002;
  };

  networking.firewall.allowedTCPPorts = [
    8191
  ];

  boot.postBootCommands = ''
    mkdir -p /persist/services/flaresolverr
    chown -R ${config.users.users.flaresolverr.uid}:${config.users.groups.flaresolverr.gid} /persist/services/flaresolverr
    chmod -R 750 /persist/services/flaresolverr
  '';
}
