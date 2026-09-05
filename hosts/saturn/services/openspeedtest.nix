{config, ...}: let
  serviceName = "openspeedtest";
  serviceId = 1022;
in {
  virtualisation.oci-containers.containers = {
    "${serviceName}" = {
      autoStart = true;
      image = "docker.io/openspeedtest:latest";
      pull = "newer";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      ports = [
        "8337:80/tcp"
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
    8337
  ];

  boot.postBootCommands = let
    uid = builtins.toString config.users.users."${serviceName}".uid;
    gid = builtins.toString config.users.groups."${serviceName}".gid;
  in ''
    mkdir -p /var/lib/${serviceName}
    chown ${uid}:${gid} /var/lib/${serviceName}
    chmod 750 /var/lib/${serviceName}
  '';

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/${serviceName}/.local/share/containers";
      user = serviceName;
      group = serviceName;
      mode = "0700";
    }
  ];
}
