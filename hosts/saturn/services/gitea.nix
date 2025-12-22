{config, ...}: {
  virtualisation.oci-containers.containers = {
    gitea = {
      autoStart = true;
      image = "docker.gitea.com/gitea@sha256:36a8f50113d4dff6036707fd716c10147a0ab472bb21dc7d3ddda9ae6c20c873";
      user = "${builtins.toString config.users.users.gitea.uid}:${builtins.toString config.users.groups.gitea.gid}";
      podman = {
        sdnotify = "healthy";
        user = "gitea";
      };
      extraOptions = [
        "--cap-drop=ALL"
        "--userns=keep-id"
        "--health-cmd"
        "curl -f http://localhost:3000 || exit 1"
        "--health-interval"
        "30s"
        "--health-retries"
        "3"
      ];
      ports = [
        "2222:2222/tcp"
        "3000:3000/tcp"
      ];
      volumes = [
        "/persist/services/gitea/data:/var/lib/gitea"
        "/persist/services/gitea/config:/etc/gitea"
        "/etc/timezone:/etc/timezone:ro"
        "/etc/localtime:/etc/localtime:rodata:ro"
      ];
    };
  };

  users.users.gitea = {
    isNormalUser = true;
    linger = true;
    packages = [config.virtualisation.podman.package];
    uid = 1004;
    group = "gitea";
  };

  users.groups.gitea = {
    gid = 1004;
  };

  networking.firewall.allowedTCPPorts = [
    3000
    2222
  ];

  boot.postBootCommands = ''
    mkdir -p /persist/services/gitea/{config,data}
    chown -R ${builtins.toString config.users.users.gitea.uid}:${builtins.toString config.users.groups.gitea.gid} /persist/services/gitea
    chmod -R 750 /persist/services/gitea
  '';
}
