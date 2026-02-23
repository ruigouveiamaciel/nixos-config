{config, ...}: let
  serviceName = "seerr";
  serviceId = 1014;
in {
  virtualisation.oci-containers.containers = {
    "${serviceName}" = {
      autoStart = true;
      image = "ghcr.io/seerr-team/seerr:latest";
      pull = "newer";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      environment = {
        TZ = config.time.timeZone;
        PORT = "5055";
      };
      ports = [
        "10.0.50.42:5055:5055/tcp"
      ];
      volumes = [
        "/persist/services/${serviceName}/config:/app/config:U"
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
    5055
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
