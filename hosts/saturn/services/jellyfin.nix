{config, ...}: let
  serviceName = "jellyfin";
  serviceId = 1007;
in {
  virtualisation.oci-containers.containers = {
    "${serviceName}" = {
      autoStart = true;
      image = "docker.io/jellyfin/jellyfin:latest";
      pull = "newer";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      extraOptions = [
        "--device=/dev/dri:/dev/dri"
      ];
      ports = [
        "10.0.50.10:8096:8096/tcp"
        "10.0.50.42:8096:8096/tcp"
      ];
      volumes = [
        "/persist/services/${serviceName}/config:/config:U"
        "/persist/services/${serviceName}/cache:/cache:U"
        "/persist/forced/media/movies:/data/movies:ro"
        "/persist/forced/media/tvshows:/data/tvshows:ro"
        "/persist/forced/media/anime:/data/anime:ro"
        "/persist/forced/media/test:/data/test:ro"
        "/persist/forced/media/personal:/data/personal:ro"
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
    8096
  ];

  boot.postBootCommands = let
    uid = builtins.toString config.users.users."${serviceName}".uid;
    gid = builtins.toString config.users.groups."${serviceName}".gid;
  in ''
    mkdir -p /persist/services/${serviceName}/{config,cache}
    chown ${uid}:${gid} -R /persist/services/${serviceName}
    chmod 750 -R /persist/services/${serviceName}
  '';
}
