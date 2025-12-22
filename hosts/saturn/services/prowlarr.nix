{config, ...}: {
  virtualisation.oci-containers.containers = {
    prowlarr = {
      autoStart = true;
      image = "docker.io/linuxserver/prowlarr@sha256:aeb303a86be70dfb3fa5508bbd9399f5123b74f73b00b91eb76eb34efe4c5650";
      podman = {
        sdnotify = "healthy";
        user = "prowlarr";
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
        "curl -f http://localhost:9696 || exit 1"
        "--health-interval"
        "30s"
        "--health-retries"
        "3"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = builtins.toString config.users.users.prowlarr.uid;
        PGID = builtins.toString config.users.groups.prowlarr.gid;
      };
      ports = [
        "9696:9696/tcp"
      ];
      volumes = [
        "/persist/services/prowlarr:/config"
      ];
    };
  };

  users.users.prowlarr = {
    isNormalUser = true;
    linger = true;
    packages = [config.virtualisation.podman.package];
    uid = 1010;
    group = "prowlarr";
  };

  users.groups.prowlarr = {
    gid = 1010;
  };

  networking.firewall.allowedTCPPorts = [
    9696
  ];

  boot.postBootCommands = ''
    mkdir -p /persist/services/prowlarr
    chown -R ${builtins.toString config.users.users.prowlarr.uid}:${builtins.toString config.users.groups.prowlarr.gid} /persist/services/prowlarr
    chmod -R 750 /persist/services/prowlarr
  '';
}
