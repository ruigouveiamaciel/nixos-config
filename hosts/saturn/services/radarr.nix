{config, ...}: let
  serviceName = "radarr";
  serviceId = 1012;
in {
  virtualisation.oci-containers.containers = {
    "${serviceName}" = {
      autoStart = true;
      image = "lscr.io/linuxserver/radarr:latest";
      pull = "newer";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      environment = {
        TZ = config.time.timeZone;
        PUID = builtins.toString config.users.users."${serviceName}".uid;
        PGID = builtins.toString config.users.groups."${serviceName}".gid;
      };
      ports = [
        "10.0.50.42:7878:7878/tcp"
      ];
      volumes = [
        "/persist/services/${serviceName}/config:/config:U"
        "/persist/forced/media/movies:/data/movies"
        "/persist/forced/media/downloads:/downloads"
      ];
    };
  };

  users.groups."${serviceName}".gid = serviceId;
  users.users."${serviceName}" = {
    isNormalUser = true;
    linger = true;
    packages = [config.virtualisation.podman.package];
    uid = serviceId;
    group = serviceName;
    home = "/var/lib/${serviceName}";
    createHome = true;
    subUidRanges = [
      {
        count = 65536;
        startUid = serviceId * 100000;
      }
    ];
    subGidRanges = [
      {
        count = 65536;
        startGid = serviceId * 100000;
      }
    ];
  };

  networking.firewall.interfaces.enp90s0.allowedTCPPorts = [
    7878
  ];

  boot.postBootCommands = let
    uid = builtins.toString config.users.users."${serviceName}".uid;
    gid = builtins.toString config.users.groups."${serviceName}".gid;
  in ''
    mkdir -p /persist/services/${serviceName}/config
    chown ${uid}:${gid} -R /persist/services/${serviceName}
    chmod 750 -R /persist/services/${serviceName}
  '';
}
