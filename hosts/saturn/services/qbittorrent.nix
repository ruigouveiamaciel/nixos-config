{config, ...}: let
  serviceName = "qbittorrent";
  serviceId = 1011;
in {
  virtualisation.oci-containers.containers = {
    "${serviceName}" = {
      autoStart = true;
      image = "docker.io/linuxserver/qbittorrent:latest";
      pull = "newer";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      environment = {
        TZ = config.time.timeZone;
        PUID = builtins.toString config.users.users.qbittorrent.uid;
        PGID = builtins.toString config.users.groups.qbittorrent.gid;
        WEBUI_PORT = "1338";
        TORRENTING_PORT = "6881";
      };
      ports = [
        "10.0.50.42:1338:1338/tcp"
        "10.0.50.42:6881:6881/tcp"
        "10.0.50.42:6881:6881/udp"
      ];
      volumes = [
        "/persist/services/${serviceName}/data:/config:U"
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
  networking.firewall.interfaces.enp90s0 = {
    allowedTCPPorts = [
      1338
      6881
    ];
    allowedUDPPorts = [
      6881
    ];
  };

  boot.postBootCommands = let
    uid = builtins.toString config.users.users."${serviceName}".uid;
    gid = builtins.toString config.users.groups."${serviceName}".gid;
  in ''
    mkdir -p /persist/services/${serviceName}/data
    chown ${uid}:${gid} -R /persist/services/${serviceName}
    chmod 750 -R /persist/services/${serviceName}
  '';
}
