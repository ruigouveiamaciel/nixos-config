{config, ...}: {
  virtualisation.oci-containers.containers = {
    flaresolverr = {
      autoStart = true;
      image = "docker.io/flaresolverr/flaresolverr@sha256:524715c5b5d045ff77ae409ffa1d6c0fcf9f23a2e5e957eb44da4f2fc53e6876";
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
        "30s"
        "--health-retries"
        "3"
      ];
      ports = [
        "8191:8191/tcp"
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
    chown -R ${builtins.toString config.users.users.flaresolverr.uid}:${builtins.toString config.users.groups.flaresolverr.gid} /persist/services/flaresolverr
    chmod -R 750 /persist/services/flaresolverr
  '';
}
