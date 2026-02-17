{
  config,
  pkgs,
  ...
}: {
  virtualisation.oci-containers.containers = {
    forgejo = {
      autoStart = true;
      image = "codeberg.org/forgejo/forgejo:13";
      pull = "newer";
      podman = {
        sdnotify = "healthy";
        user = "forgejo";
      };
      capabilities = {
        CAP_SETUID = true;
        CAP_SETGID = true;
        CAP_CHOWN = true;
        CAP_FOWNER = true;
        CAP_DAC_OVERRIDE = true;
        CAP_NET_BIND_SERVICE = true;
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
      environment = {
        USER_UID = builtins.toString config.users.users.forgejo.uid;
        USER_GID = builtins.toString config.users.groups.forgejo.gid;
      };
      ports = [
        "2222:2222/tcp"
        "3000:3000/tcp"
      ];
      volumes = let
        tzFile = pkgs.writeText "timezone" "${config.time.timeZone}\n";
      in [
        "/persist/services/forgejo:/data"
        "${tzFile}:/etc/timezone:ro"
        "/etc/localtime:/etc/localtime:ro"
      ];
    };
  };

  users.users.forgejo = {
    isNormalUser = true;
    linger = true;
    packages = [config.virtualisation.podman.package];
    uid = 1004;
    group = "forgejo";
  };

  users.groups.forgejo = {
    gid = 1004;
  };

  networking.firewall.allowedTCPPorts = [
    3000
    2222
  ];

  boot.postBootCommands = ''
    mkdir -p /persist/services/forgejo
    chown ${builtins.toString config.users.users.forgejo.uid}:${builtins.toString config.users.groups.forgejo.gid} /persist/services/forgejo
    chmod 750 /persist/services/forgejo
  '';
}
