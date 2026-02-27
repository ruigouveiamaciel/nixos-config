{config, ...}: let
  serviceName = "navidrome";
  serviceId = 1009;
in {
  virtualisation.oci-containers.containers = {
    "${serviceName}" = {
      autoStart = true;
      image = "docker.io/deluan/navidrome:latest";
      pull = "newer";
      user = "${builtins.toString config.users.users."${serviceName}".uid}:${builtins.toString config.users.groups."${serviceName}".gid}";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      ports = [
        "10.0.50.10:4533:4533/tcp"
        "10.0.50.42:4533:4533/tcp"
      ];
      volumes = [
        "/persist/services/${serviceName}/config:/data:U"
        "/persist/forced/media/music:/music:ro"
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
    4533
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
